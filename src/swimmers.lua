function i_shark()
  shark_timing=.05
  patrol_time=120
  max_dead_time=720
  fish_frames={
    {80,81}, -- tuna
    {82,83}, -- clown
    {84,85}, -- sea horse
  };

  swimmer = class {
    state='patrol'; -- patrol, chase, attacking, dead, caught
    type='shark'; -- shark, fish, crab
    dead_t=0;
    x=20;
    y=20;
    w=16;
    h=8;
    speed=.3;
    flip_x=true; -- left
    is_hooked=false;
    was_hooked=false;
    patrol_t=0;
    swim_frames={};
    attack_frames={};
    fr=1;

    init=function(self, type, x, y, w, h, flip_x)
      self.x=x or self.x
      self.y=y or self.y
      self.w=w or self.w
      self.h=h or self.h
      self.type=type or self.type
      self.flip_x=flip_x or self.flip_x
    end;


    travel_with_claw = function(self)
      if (self.is_hooked) then
        self.x = tgsub.claw.x-4
        self.y = tgsub.claw.y
      end
    end;

    captured_by_sub=function(self)
      if (self.is_hooked and check_collision(self, tgsub)) then
        tgsub.claw.cargo = nil
        if (self.state!='dead' and self.type=='fish') gain_trophy('for_my_aquarium')
        if (self.state!='dead' and self.type=='shark') gain_trophy('super_wrangler')
        if (self.state=='dead' and self.type=='fish') gain_trophy('for_my_wall')
        self:destroy()
      end
    end;

    collide_w_bullet=function(self)
      for i, b in pairs(tgsub.torpedoes) do
        if (self.state != 'dead' and check_collision(self, b)) then
          self:kill()
          b:explode()
          b:destroy()
        elseif (self.state == 'dead' and check_collision(self, b)) then
          add_explosion(self.x+4, self.y, 40)

          breakup(self.x, self.y, 6)
          b:explode()
          b:destroy()
          self:destroy()
          gain_trophy('and_stay_dead')
        end
      end
    end;

    collide_w_claw=function(self)
      if (check_collision(self, tgsub.claw) and not tgsub.claw.is_open) then
        if (not self.is_hooked) sfx(9)
        self.is_hooked = true
        self.was_hooked = true
        tgsub.cargo=self
      else
        self.is_hooked = false
        tgsub.cargo=nil
      end
    end;

    animate=function(self, frame_count)
      self.fr += shark_timing
      if (self.fr > frame_count) then
        self.fr = 1
      end
    end;

    kill=function(self)
      self.state = 'dead'
    end;

    destroy=function(self)
      del(world[self.type], self)
    end;
  }
  shark = swimmer:extend {
    init=function(self, x, y)
      swimmer.init(self, 'shark', x, y, 16, 8, true)
      self.x=x or self.x
      self.y=y or self.y
      self.swim_frames={68, 70};
      self.attack_frames={64, 66};
    end;

    update=function(self)
      local dist_to_sub = dst(self, tgsub)
      local col_sub_left = check_collision(self, tgsub)
      local col_sub_right = check_collision(self, tgsub)
      local col_sub_top = check_collision(self, tgsub)
      local col_sub_bottom = check_collision(self, tgsub)

      local col_world_left = collide_map(self, 'left', 0)
      local col_world_right = collide_map(self, 'right', 0)
      local col_world_top = collide_map(self, 'top', 0)
      local col_world_bottom = collide_map(self, 'bottom', 0)

      -- if collide with bullet, die
      self:collide_w_bullet()

      -- if collide with claw, get caught
      self:collide_w_claw()
      self:travel_with_claw()
      self:captured_by_sub()

      -- live sharks patrol back and forth
      if (self.state != 'dead' and not self.is_hooked) then
        -- watch for tgsub and give chase
        if (dist_to_sub < 45) then
          self.state = 'chase'
          self.speed = .5
        else
          self.state = 'patrol'
        end

        if (self.state == 'patrol') then
          if (self.patrol_t < patrol_time) then
            if (self.flip_x) then
              self.x+=self.speed
            elseif (not self.flip_x) then
              self.x-=self.speed
            end
          elseif (self.patrol_t >= patrol_time) then
            self.patrol_t = 0
            self.flip_x = not self.flip_x
          end
          self.patrol_t+=1
        end

        if (self.state == 'chase' or self.state == 'attacking') then
          if (self.x < tgsub.x) then
            self.flip_x = true
            if (col_sub_right) then
              self.state = 'attacking'
              self.x-=self.speed+5
              tgsub:crash(3)
            elseif (not col_world_right) then
              self.x+=self.speed
            end
          elseif (self.x > tgsub.x) then
            self.flip_x = false
            if (col_sub_left) then
              self.state = 'attacking'
              self.x+=self.speed+5
              tgsub:crash(3)
            elseif (not col_world_left) then
              self.x-=self.speed
            end
          end

          if (self.y < tgsub.y) then
            if (not col_world_bottom) then
              self.y+=self.speed
            elseif (col_sub_bottom) then
              self.y-=self.speed+5
              tgsub:crash(3)
            end
          elseif (self.y > tgsub.y) then
            if (not col_world_top) then
              self.y-=self.speed
            elseif (col_sub_top) then
              self.y+=self.speed+5
              tgsub:crash(3)
            end
          end
        end
      end

      if self.state == 'dead' then
        if self.dead_t < max_dead_time then
          self.dead_t+=1
        else
          self:destroy()
        end
      end

      if (self.state == 'dead' and self.y >= world.water_surface) then
        self.y-=.2
      elseif (self.state != 'dead') then
        self:animate(3)
      end

      if (not self.is_hooked and self.was_hooked) then
        self.was_hooked = false
        gain_trophy('catch_and_release')
      end

    end;

    draw=function(self)
      -- DEBUGGING
      -- print(self.state, self.x-2, self.y-10, 11)
      -- print('torpedoes: '..#tgsub.torpedoes, self.x-2, self.y-18, 11)
      -- print('dist: '..dst(self, tgsub), self.x-2, self.y-2, 11)
      -- print('patrol_t: '..self.patrol_t, self.x-2, self.y-2, 11)

      -- draw shark animated sprite
      if (self.state == 'chase' or self.state == 'attacking') then
        spr(self.attack_frames[flr(self.fr)], self.x, self.y, 2, 1, self.flip_x)
      elseif ( self.state == 'patrol') then
        spr(self.swim_frames[flr(self.fr)], self.x, self.y, 2, 1, self.flip_x)
      elseif (self.state == 'dead') then
        spr(70, self.x, self.y, 2, 1, self.flip_x, true)
      end
    end;
  }

  fish = swimmer:extend {
    fish_type=1; -- 1=tuna, 2=clown, 3=sea horse

    -- will init a random fish type
    init=function(self, x, y)
      swimmer.init(self, 'fish', x, y, 8, 8, true)
      self.x=x or self.x
      self.y=y or self.y
      self.fish_type=flr(rnd(3))+1
      self.swim_frames=fish_frames[self.fish_type]
      self.patrol_time = flr(rnd(220))+60
    end;

    update=function(self)
      local col_world_left = collide_map(self, 'left', 0)
      local col_world_right = collide_map(self, 'right', 0)
      local col_world_top = collide_map(self, 'top', 0)
      local col_world_bottom = collide_map(self, 'bottom', 0)

      -- if collide with bullet, die
      self:collide_w_bullet()
      self:collide_w_claw()
      self:travel_with_claw()
      self:captured_by_sub()

      -- live fishs patrol back and forth
      if (self.state != 'dead' and not self.is_hooked) then
        -- watch for tgsub and give chase
        if (self.state == 'patrol') then
          if (self.patrol_t < self.patrol_time) then
            if (not col_world_left and self.flip_x) then
              self.x+=self.speed
            elseif (col_world_left or not self.flip_x) then
              self.x-=self.speed
            end
          elseif (self.patrol_t >= self.patrol_time) then
            self.patrol_t = 0
            self.flip_x = not self.flip_x
          end

          -- randomize up and down movement using patrol time
          if (not col_world_top and self.patrol_t < self.patrol_time/2) then
            self.y-=.1
          elseif (not col_world_bottom and self.patrol_t >= self.patrol_time/2) then
            self.y+=.1
          end

          self.patrol_t+=1
        end
      end

      if self.state == 'dead' then
        if self.dead_t < max_dead_time then
          self.dead_t+=1
        else
          self:destroy()
        end
      end

      if (self.state == 'dead' and self.y >= world.water_surface) then
        self.y-=.2
      elseif (self.state != 'dead') then
        self:animate(3)
      end

      if (not self.is_hooked and self.was_hooked) then
        gain_trophy('no_sushi_tonight')
        self.was_hooked = false
      end
    end;

    draw=function(self)
      -- draw fish animated sprite
      if (self.state == 'patrol') then
        spr(self.swim_frames[flr(self.fr)], self.x, self.y, 1, 1, self.flip_x)
      elseif (self.state == 'dead') then
        spr(self.swim_frames[1], self.x, self.y, 1, 1, self.flip_x, true)
      end
    end;
  }
end

