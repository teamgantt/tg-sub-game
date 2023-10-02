function i_dyn_objs()
  chest = class {
    init = function(self, x, y)
      self.x = x
      self.y = y
      self.w = 8
      self.h = 8
      self.dy = 0
      self.is_hooked = false
      self.show_hint = false
      self.img = 59 -- closed chest
      self.is_open = false
    end,
    update = function(self, dt)
      if self.is_open then
        self.img = 60 -- is_open chest
      end

      if (check_collision(self, player.diver)) then
        self.show_hint = true
        if (player.mode == 'diver' and btn(⬇️) and not self.is_open) then
          self.is_open = true
          sfx(5)

          -- spawn treasure
          local treasure = treasure(self.x, self.y)
          add(world.treasures, treasure)
        end
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
        self.y+=.2
      end
    end,
    draw = function(self)
      if (self.show_hint and not self.is_open) then
        print('⬇️ OPEN', self.x-8, self.y-10, 7)
      end
      spr(self.img, self.x, self.y)
    end,
  }

  treasure = class {
    init = function(self, x, y, type, img)
      self.x = x
      self.y = y
      self.w = 8
      self.h = 8
      self.dy = 0
      self.is_carried = false
      self.is_hooked = false
      self.img = img or 61 -- treasure
      self.show_hint = false
      self.type = type or 'treasure'
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
        self.y+=.2
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
        self.y+=.2
      end

      -- collect with sub collision
      if (check_collision(self, tgsub)) then
        tgsub.claw.cargo = nil
        player[self.type]+=1
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

  clam = class {
    init = function(self, x, y)
      self.x = x-8
      self.y = y-8
      self.w = 16
      self.h = 16
      self.img = 12 -- closed clam
      self.open = false
    end,
    update = function(self, dt)
      if self.open then
        self.img = 14 -- open clam
      end


      if (check_collision(self, player.diver)) then
        if (btnp(⬇️) and not self.open) then
          self.open = true
          sfx(6)

          -- spawn pearl
          local pearl = treasure(self.x+4, self.y, 'pearl', 96)
          add(world.treasures, pearl)
        end
      end
    end,
    draw = function(self)
      spr(self.img, self.x, self.y, 2, 2, false, false)
    end,
    collision = function(self, other)
      if (check_collision(self, other)) return true
    end
  }
end
