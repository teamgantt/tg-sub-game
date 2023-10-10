function i_dyn_objs()
  dyn_obj_grav=.5
  treasure_types = {"coin", "wrench"}
  dyn_obj = class {
    init = function(self, type, x, y, w, h, spr_num)
      self.type = type
      self.x = x
      self.y = y
      self.w = w or 8
      self.h = w or 8
      self.is_hooked = false
      self.img = spr_num
      self.dy = 0
      self.dx = 0
    end;

    draw = function(self)
      spr(self.img, self.x, self.y, self.w/8, self.h/8, false, false)
    end;
  }

  chest = dyn_obj:extend {
    init = function(self, x, y)
      dyn_obj.init(self, 'chest', x, y, 8, 8, 59)
      self.is_hooked = false
      self.show_hint = false
      self.is_open = false
    end;

    collide_w_bullet=function(self)
      for i, b in pairs(tgsub.torpedoes) do
        if (not self.is_hooked and check_collision(self, b)) then
          add_explosion(self.x+4, self.y, 50)

          b:destroy()
          self:destroy()
          gain_trophy('brute_force')
        end
      end
    end;

    destroy = function(self)
      del(world.chests, self)
    end;

    update = function(self, dt)
      if self.is_open then
        self.img = 60 -- is_open chest
      end

      -- collide with bullet
      self:collide_w_bullet()

      if (check_collision(self, player.diver)) then
        self.show_hint = true
        if (player.mode == 'diver' and btn(⬇️) and not self.is_open) then
          self.is_open = true
          sfx(5)

          -- spawn treasure
          add(world.treasures, treasure(treasure_types[flr(rnd(2))+1], self.x, self.y))
        end
      else
        self.show_hint = false
      end

      -- collide with sub claw
      if (not tgsub.claw.is_open and tgsub.cargo == nil and check_collision(self, tgsub.claw)) then
        self.is_hooked = true
        tgsub.claw.cargo = self
      else
        self.is_hooked = false
      end

      -- if treasure is hooked, move with claw
      if (self.is_hooked) then
        self.x = tgsub.claw.x-4
        self.y = tgsub.claw.y
      end

      if (self.is_hooked or collide_map(self, 'down', 0)) then
        self.dy = 0
      else
        self.y+=dyn_obj_grav
      end
    end;
    draw = function(self)
      if (self.show_hint and not self.is_open) then
        print('⬇️ OPEN', self.x-8, self.y-10, 7)
      end
      spr(self.img, self.x, self.y)
    end;
  }

  treasure = dyn_obj:extend {
    init = function(self, type, x, y)
      local spr_num = 61
      if (type == 'pearl') spr_num = 96
      if (type == 'wrench') spr_num = 116
      dyn_obj.init(self, type, x, y, 8, 8, spr_num)
      self.is_carried = false
      self.is_hooked = false
      self.show_hint = false
    end,
    update = function(self, dt)
      if (check_collision(self, player.diver)) then
        self.show_hint = true

        if (btnp(⬇️) and not self.is_carried) then
          self.is_carried = true
          sfx(7)
        elseif ((btnp(⬇️)) and self.is_carried) then
          self.is_carried = false
          sfx(7)
        end
      else
        self.show_hint = false
      end

      if self.is_carried and player.mode == 'diver' then
        -- hold treasure in front of player depending on direction
        if player.diver.flipx then
          self.x = player.diver.x - 8
          self.y = player.diver.y
        elseif not player.diver.flipx then
          self.x = player.diver.x + 8
          self.y = player.diver.y
        end
      else
        self.is_carried = false
      end

      -- handle world collisions
      -- if treasure is not carried, collide with world
      if (self.is_carried or collide_map(self, 'down', 0)) then
        self.dy = 0
      else
        self.y+=dyn_obj_grav
      end
     -- collide with sub claw
     if (not tgsub.claw.is_open and tgsub.cargo == nil and check_collision(self, tgsub.claw)) then
        self.is_hooked = true
        tgsub.claw.cargo = self
      else
        self.is_hooked = false
      end

      -- if treasure is hooked, move with claw
      if (self.is_hooked) then
        self.x = tgsub.claw.x-4
        self.y = tgsub.claw.y
      end

      if (self.is_hooked or collide_map(self, 'down', 0)) then
        self.dy = 0
      else
        self.y+=dyn_obj_grav
      end

      -- collect with sub collision
      if (check_collision(self, tgsub)) then
        tgsub.claw.cargo = nil
        if (player[self.type]!=nil) player[self.type]+=1
        if (self.type == 'wrench') tgsub:repair()
        sfx(10)
        del(world.treasures, self)
      end
    end,
    draw = function(self)
      -- print('is_carried: '..tostr(self.is_carried), self.x-8, self.y-18, 7)
      if player.mode == 'diver' then
        if self.show_hint and not self.is_carried then
          print('⬇️ GRAB', self.x-8, self.y-10, 7)
        elseif self.show_hint and self.is_carried then
          print('⬇️ DROP', self.x-8, self.y-10, 7)
        end
      end
      spr(self.img, self.x, self.y)
    end,
  }

  clam = dyn_obj:extend {
    init = function(self, x, y)
      dyn_obj.init(self, 'clam', x-8, y-8, 16, 16, 12)
      self.is_open = false
    end,
    update = function(self, dt)
      if (self.is_open) self.img = 14

      if (check_collision(self, player.diver)) then
        if (btnp(⬇️) and not self.is_open) then
          self.is_open = true
          sfx(6)

          -- spawn pearl
          local pearl = treasure('pearl', self.x+4, self.y)
          add(world.treasures, pearl)
        end
      end
    end,
  }
end
