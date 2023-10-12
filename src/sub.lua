function i_sub()
  def_friction=.90
	sub_gravity=0.001
  sub_friction=def_friction
  torpedo = class {
    name='torpedo';
    x=0;
    y=0;
    dx=0;
    dy=0;
    w=4;
    h=4;
    speed=3;
    timer=0;
    is_active=false;
    flipx=false;
    init=function(self, x, y, dx, dy, flipx)
      self.x = x-2
      self.y = y
      self.dx = self.speed
      self.dy = dy
      self.is_active = false
      self.flipx = flipx or false
    end;
    update=function(self)
      if (not self.is_active) then
        self.timer+=2
        self.dy=.3

        if (self.timer > 45) then
          self.is_active = true
          self.dy=0
        end
      end

      -- launch torpedo
      if (self.is_active) then
        sfx(11)
        if (not self.flipx) then
          self.x+=self.dx
        else
          self.x-=self.dx
        end
        -- every 4 frames, add bubbles
        local bub_dir = 'r'
        if (self.flipx) bub_dir = 'l'
        if (tick%4 == 0) add_bubble(self.x+2, self.y+4, bub_dir, 20)
      end

      -- always apply dy
      self.y+=self.dy

      -- handle collisionss
      if (collide_map(self, 'right', 0) or collide_map(self, 'left', 0)) then
        self:destroy()
        self:explode()
      end

      -- if outside of camera bounds, remove
      if (self.x < cam_x or self.x > cam_x+128) then
        self:destroy()
      end
    end;
    explode=function(self)
      add_explosion(self.x+4, self.y, 40)
      sfx(12)
    end;
    draw=function(self)
      spr(62, self.x, self.y, 1, 1, self.flipx)
    end;
    destroy=function(self)
      del(tgsub.torpedoes, self)
    end;
  }

  tgsub={
    torp_loading=0,
    torpedoes={},
    show_menu=false,
    mode='claw', -- claw, torpedo, diver
    hull=100,
    x=20,
    y=40,
    w=16,
    h=13,
    dx=0,
    dy=0,
    max_dx=2,
    max_dy=2,
    speed=.25,
    flipx=false,
    claw_len=0,
    claw={
      x=0,
      y=0,
      w=6,
      h=6,
      is_open=true,
      cargo=nil,
    },
    repair=function(self)
      if (self.hull < 100) then
        self.hull=100
      end
    end,
    shoot = function(self)
      if (self.mode == 'torpedo' and self.torp_loading >= 16) then
        sfx(9)
        add(self.torpedoes, torpedo(self.x+8, self.y+8, self.dx, self.dy, self.flipx))
        self.torp_loading = 0
      end
    end,
    crash = function(self, dmg)
      shake_int = 6
      sfx(4)
      add_sparks(self.x+4, self.y+8, 40)
      add_sparks(self.x+12, self.y+12, 40)
      add_sparks(self.x+12, self.y+12, 40)

      -- reduce hull
      if (self.hull > 0 and dmg == nil) then
        self.hull-=5
      elseif (self.hull > 0) then
        self.hull-=dmg
      end

      if (self.hull <= 0) then
        extcmd('reset')
      end
    end
  }


  prop_bubbles={
		elapsed=0,
		step=function(timing,life)
			prop_bubbles.elapsed+=timing
			if (prop_bubbles.elapsed >= 1) then
				prop_bubbles.elapsed=0
        sfx(0)
				if tgsub.dx<0 then
          add_bubble(tgsub.x+16, tgsub.y +8,'l', rnd_between(20,40), life)
				else
          add_bubble(tgsub.x, tgsub.y +8,'r', rnd_between(20,40), life)
				end
			end
		end
	}
end

function u_sub()
  -- toggle between sub and diver on pressing x
  if (btnp(❎) and player.diver_active) then
    if (player.mode == 'diver') then
      player.mode = 'sub'
      tgsub.mode = 'claw'
    end
  -- sub menu
  elseif (btn(❎)) then
    tgsub.show_menu = true
    player.mode = 'sub'

    if (btnp(⬅️)) then
      tgsub.mode = 'claw'
    elseif (btnp(➡️)) then
      tgsub.mode = 'torpedo'
    elseif (btn(⬇️)) then
      tgsub.mode = 'diver'
    end
  else
    tgsub.show_menu = false
  end

  --apply controls
  if player.mode == 'sub' then
    if (not btn(❎) and btn(⬅️)) then
      -- first slow down
      if tgsub.dx > .1 then tgsub.dx*=sub_friction
      else
        tgsub.dx-=tgsub.speed
        tgsub.flipx = true
        prop_bubbles.step(.1)

        sfx(1)
      end
    end -- left

    if (not btn(❎) and btn(➡️)) then
      if tgsub.dx < -.1 then tgsub.dx*=sub_friction
      else
        tgsub.dx+=tgsub.speed
        tgsub.flipx = false
        prop_bubbles.step(.1)
        sfx(1)
      end
    end -- right
  end

  -- sub up and down
	if (not btn(🅾️)
      and not btn(❎)
      and btn(⬇️)
      and player.mode != 'diver'
      and not collide_map(tgsub, 'down', 0)) then
    tgsub.dy+=tgsub.speed
    prop_bubbles.step(.1, 90)
    sfx(2)
	end

  if (not btn(🅾️)
    and not btn(❎)
    and (btn(⬆️)
    and player.mode != 'diver'
    and not collide_map(tgsub, 'up', 0))) then
    tgsub.dy-=tgsub.speed
    prop_bubbles.step(.1, 90)
    sfx(2)
  end

  -- shoot torpedo
  if (tgsub.mode == 'torpedo' and btn(🅾️) and player.mode == 'sub') then
    tgsub:shoot()
  end

  --if holding z lower claw
  if (tgsub.mode == 'claw' and btn(🅾️) and player.mode == 'sub') then
    -- holding z an pressing down lowers claw
    tgsub.claw.is_open = true

    if ( not collide_map(tgsub.claw, 'down', 0)) then
      tgsub.claw_len+=1
      sfx(8)
    end
  elseif btn(🅾️) and player.mode == 'sub' and tgsub.mode == 'claw' then
    tgsub.claw.is_open = true
    sub_friction = .7
  elseif not btn(🅾️) then
    sub_friction = def_friction
    if (tgsub.claw_len > 0 and not collide_map(tgsub.claw, 'up', 0)) tgsub.claw_len-=1
    tgsub.claw.is_open = false

    if (tgsub.claw_len < 1) then
      tgsub.claw.is_open = true
    end
  end

  -- sync claw position with claw_len
  tgsub.claw.x = tgsub.x+8
  tgsub.claw.y = tgsub.y+8+tgsub.claw_len

  -- SUB MODE
  -- apply tgsub movement
  if tgsub.dy>0 then

    if collide_map(tgsub,"down",0) then
      tgsub.y-=((tgsub.y+tgsub.h+1)%8)-1
      tgsub.dy=-tgsub.dy
      tgsub:crash()
    end
  elseif tgsub.dy<0 then
    if collide_map(tgsub,"up",0) then
      tgsub.dy=-tgsub.dy
      tgsub:crash()
    end
  end

  -- check for collisions left and right
  if tgsub.dx<0 then
    if collide_map(tgsub,"left",0) then
      tgsub.dx=-tgsub.dx
      tgsub:crash()
    end
  elseif tgsub.dx>0 then
    if collide_map(tgsub,"right",0) then
      tgsub.dx=-tgsub.dx
      tgsub:crash()
    end
  end


  if (tgsub.dy > 0 and tgsub.dy < .1) tgsub.dy = 0
  if (tgsub.dy < 0 and tgsub.dy > -.1) tgsub.dy = 0
  if (tgsub.dx > 0 and tgsub.dx < .1) tgsub.dx = 0
  if (tgsub.dx < 0 and tgsub.dx > -.1) tgsub.dx = 0

  tgsub.dx=limit_speed(tgsub.dx,tgsub.max_dx)
  tgsub.dy=limit_speed(tgsub.dy,tgsub.max_dy)

  --apply sub_friction
  tgsub.dy*=sub_friction
  tgsub.dx*=sub_friction

  --apply dx and dy to player position
  tgsub.x+=tgsub.dx
  tgsub.y+=tgsub.dy

  prop_bubbles.step(.005)

  --limit player to map
  if tgsub.x<map_start then
    tgsub.x=map_start
  end

  --limit player to map
  if tgsub.x>map_end-tgsub.w then
    tgsub.x=map_end-tgsub.w
  end

  --limit tgsub.y to water surface
  if tgsub.y<world.water_surface-4 then
    tgsub.y=world.water_surface-4
  end

  --every 1/10 second, update torpedo load time
  if (tick%6 == 0) tgsub.torp_loading+=2

  -- update torpedoes
  for torpedo in all(tgsub.torpedoes) do
    if (torpedo != nil) torpedo:update()
  end
end

function d_sub()
  -- draw claw
  if (tgsub.claw_len > 0) then
    local claw_x = tgsub.x+8
    local claw_y = tgsub.y+8
    local img = 46
    if (not tgsub.claw.is_open) img=47
    line(claw_x, claw_y, claw_x, claw_y+tgsub.claw_len, 6)
    spr(img, claw_x-4, claw_y+tgsub.claw_len, 1, 1)
  end


  -- draw torpedo loading indicator
  if (tgsub.mode == 'torpedo') then
    local bar_len = tgsub.torp_loading
    if (bar_len < 16) line(tgsub.x, tgsub.y-4, tgsub.x+bar_len, tgsub.y-4, 6)
  end

  spr(1, tgsub.x, tgsub.y, 2, 2, tgsub.flipx)

  -- draw tgsub hitbox
  -- rect(tgsub.x, tgsub.y, tgsub.x+tgsub.w, tgsub.y+tgsub.h, 8)
  -- print("claw len: "..tgsub.claw_len, cam_x+2, cam_y+12, 8)
  -- print('torpedoes:'..#tgsub.torpedoes, cam_x+2, cam_y+12, 8)

  if shake_int > 0 then shake() end

  -- draw torpedoes
  for torpedo in all(tgsub.torpedoes) do
    if (torpedo != nil) torpedo:draw()
  end
end

function limit_speed(num,maximum)
  return mid(-maximum,num,maximum)
end
