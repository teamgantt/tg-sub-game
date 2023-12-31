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

    collide_w_claw=function(self)
      if (not tgsub.claw.is_open and tgsub.claw.cargo == nil and check_collision(self, tgsub.claw)) then
        self.is_hooked = true
        tgsub.claw.cargo = self
      else
        self.is_hooked = false
      end
    end;

    travel_with_claw = function(self)
      if (self.is_hooked) then
        self.x = tgsub.claw.x-4
        self.y = tgsub.claw.y
      end
    end;

    fall_if_not_hooked = function(self)
      if (self.is_hooked or collide_map(self, 'down', 0)) then
        self.dy = 0
      else
        self.y+=dyn_obj_grav
      end
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
          self.is_open=true
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

      self:collide_w_claw()
      self:travel_with_claw()
      self:fall_if_not_hooked()
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
      if (type == 'alien') spr_num = 118
      if (type == 'nemo') spr_num = 82
      if (type == 'bottle') spr_num = 104
      dyn_obj.init(self, type, x, y, 8, 8, spr_num)
      self.is_carried = false
      self.is_hooked = false
      self.show_hint = false
    end,
    update = function(self, dt)
      if (check_collision(self, player.diver)) then
        self.show_hint = true

        if (player.mode == 'diver' and btnp(⬇️) and not self.is_carried) then
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
        self.x = player.diver.x
        self.y = player.diver.y - 8
      else
        self.is_carried = false
      end

      self:collide_w_claw()
      self:travel_with_claw()
      self:fall_if_not_hooked()

      -- collect with sub collision
      if (check_collision(self, tgsub)) then
        tgsub.claw.cargo = nil
        if (player[self.type]!=nil) then
          local idx = {
            wrench = 61,
            coin = 62,
            pearl = 63,
          }
          player[self.type]+=1
          local v = player[self.type]
          dset(idx[self.type], v) -- persist pearl coins and wrenches collected

          if (self.type == 'coin' and v > 49) gain_trophy('fat_wallet_50')
          if (self.type == 'pearl' and v > 79) gain_trophy('eighty_pearl_necklace')
          if (self.type == 'wrench' and v > 24) gain_trophy('tool_collector_25')
        end
        if (self.type == 'wrench') then
          tgsub:repair()
          gain_trophy('repair_man')
        end
        if (self.type == 'alien') gain_trophy('the_claaaw')
        if (self.type == 'nemo') gain_trophy('found_nemo')
        if (self.type == 'bottle') gain_trophy('captain_planet')
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
