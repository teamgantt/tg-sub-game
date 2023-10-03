function i_fish()
  fish_timing=.05
  fish = class {
    type=1; -- 1=tuna, 2=clown, 3=sea horse
    state='patrol'; -- patrol, dead
    x=20;
    y=20;
    w=16;
    h=8;
    speed=.2;
    flip_x=true; -- left
    patrol_t=0;
    patrol_time=120;
    swim_frames={
      {80,81},
      {82,83},
      {84,85},
    };
    fr=1;

    init=function(self, x, y, type)
      self.x=x or self.x
      self.y=y or self.y
      self.type=type or self.type

      self.patrol_time = flr(rnd(220))+60
    end;

    animate=tick_frames;

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
      for i, b in pairs(tgsub.torpedoes) do
        if (check_collision(self, b)) then
          self:kill()
          b:destroy()

          add_explosion(self.x+4, self.y, 40)
        end
      end


      -- live fishs patrol back and forth
      if (self.state != 'dead') then
        -- watch for tgsub and give chase
        if (self.state == 'patrol') then
          if (self.patrol_t < self.patrol_time) then
            if (self.flip_x) then
              self.x+=self.speed
            elseif (not self.flip_x) then
              self.x-=self.speed
            end
          elseif (self.patrol_t >= self.patrol_time) then
            self.patrol_t = 0
            self.flip_x = not self.flip_x
          end

          -- randomize up and down movement using patrol time
          if (self.patrol_t < self.patrol_time/2) then
            self.y-=.1
          elseif (self.patrol_t >= self.patrol_time/2) then
            self.y+=.1
          end

          self.patrol_t+=1
        end
      end

      if (self.state == 'dead' and self.y >= world.water_surface) then
        self.y-=.2
      elseif (self.state == 'dead' and self.y < world.water_surface+1) then
        self:destroy()
      elseif (self.state != 'dead') then
        self:animate(3)
      end

    end;

    draw=function(self)
      -- draw fish animated sprite
      if (self.state == 'patrol') then
        spr(self.swim_frames[self.type][flr(self.fr)], self.x, self.y, 1, 1, self.flip_x)
      elseif (self.state == 'dead') then
        spr(self.swim_frames[self.type][1], self.x, self.y, 1, 1, self.flip_x, true)
      end
    end;

    kill=function(self)
      self.state = 'dead'
    end;

    destroy=function(self)
      del(world.fish, self)
    end;
  }
end

function tick_frames(self, frame_count)
	self.fr += fish_timing
	if (self.fr > frame_count) then
		self.fr = 1
	end
end
