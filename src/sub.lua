function i_sub()
	sub_gravity=0.001
  sub_friction=.95
  tgsub = {}
  tgsub.hull = 100
  tgsub.x = 20
  tgsub.y = 220
  tgsub.w = 16
  tgsub.h = 13
  tgsub.dx = 0
  tgsub.dy = 0
  tgsub.max_dx = 0.7
  tgsub.max_dy = 0.5
  tgsub.speed = 0.5
  tgsub.flipx = false
  tgsub.claw_len = 0
  tgsub.claw={}
  tgsub.claw.x=0
  tgsub.claw.y=0
  tgsub.claw.w=8
  tgsub.claw.h=8
  tgsub.claw.is_open=true
  tgsub.claw.cargo=nil
  tgsub.crash = function(self)
    shake_int = 6
    sfx(4)
    add_sparks(tgsub.x+4, tgsub.y+8, 40)
    add_sparks(tgsub.x+12, tgsub.y+12, 40)
    add_sparks(tgsub.x+12, tgsub.y+12, 40)

    -- reduce hull
    if (tgsub.hull > 0) tgsub.hull-=5

    if (tgsub.hull <= 0) then
      extcmd('reset')
    end
  end

  prop_bubbles={
		elapsed=0,
		step=function(timing)
			prop_bubbles.elapsed+=timing
			if (prop_bubbles.elapsed >= 1) then
				prop_bubbles.elapsed=0
        sfx(0)
				if tgsub.dx<0 then
          add_bubble(tgsub.x+16, tgsub.y +8,'l', rnd_between(20,40))
				else
          add_bubble(tgsub.x, tgsub.y +8,'r', rnd_between(20,40))
				end
			end
		end
	}
end

function u_sub()
  -- shake screen
  --apply sub_friction
  tgsub.dy*=sub_friction
  tgsub.dx*=sub_friction

  --apply controls
  if (btn(⬅️) and player.mode == 'sub') then
    -- first slow down
    if tgsub.dx > .1 then tgsub.dx*=sub_friction
    else
      tgsub.dx-=tgsub.speed
      tgsub.flipx = true
      tgsub.dy=0
      prop_bubbles.step(.05)
      prop_bubbles.step(.03)
      sfx(1)
    end
    tgsub.dy=-sub_gravity
	end -- left


	if (btn(➡️) and player.mode == 'sub') then
    if tgsub.dx < -.1 then tgsub.dx*=sub_friction
    else
      tgsub.dx+=tgsub.speed
      tgsub.flipx = false
      prop_bubbles.step(.05)
      prop_bubbles.step(.03)
      sfx(1)
    end
    tgsub.dy=-sub_gravity
	end -- right

  -- no left or right
	if (not btn(🅾️) and btn(⬇️) and player.mode != 'diver' and not collide_map(tgsub, 'down', 0)) then
    tgsub.dy+=tgsub.speed
    prop_bubbles.step(.03, 90)
    sfx(2)
	end

  if not btn(🅾️) and (btn(⬆️) and player.mode != 'diver' and not collide_map(tgsub, 'up', 0)) then
    tgsub.dy-=tgsub.speed
    prop_bubbles.step(.03, 90)
    sfx(2)
  end

  --if holding z lower claw
  if (btn(🅾️) and player.mode == 'sub') then
    -- holding z an pressing down lowers claw
    tgsub.claw.is_open = true

    if (btn(⬇️) and not collide_map(tgsub.claw, 'down', 0)) then
      tgsub.claw_len+=.5
      sfx(8)
    end
  elseif not btn(🅾️) then
    if (tgsub.claw_len > 0) tgsub.claw_len-=.5
    if (tgsub.claw.is_open) sfx(9)
    tgsub.claw.is_open = false

    -- -- release z to open claw
    tgsub.claw.cargo = nil
    -- if tgsub.claw.cargo then
    -- end
  end

  -- sync claw position with claw_len
  tgsub.claw.x = tgsub.x+8
  tgsub.claw.y = tgsub.y+8+tgsub.claw_len

  -- SUB MODE
  -- apply tgsub movement
  if tgsub.dy>0 then
    tgsub.dy=limit_speed(tgsub.dy,tgsub.max_dy)

    if collide_map(tgsub,"down",0) then
      tgsub.y-=((tgsub.y+tgsub.h+1)%8)-1
      tgsub.dy=-tgsub.dy
      tgsub.crash()
    end
  elseif tgsub.dy<0 then
    tgsub.dy=limit_speed(tgsub.dy,tgsub.max_dy)
    if collide_map(tgsub,"up",0) then
      tgsub.dy=-tgsub.dy
      tgsub.crash()
    end
  end

  -- check for collisions left and right
  if tgsub.dx<0 then
    tgsub.dx=limit_speed(tgsub.dx,tgsub.max_dx)
    if collide_map(tgsub,"left",0) then
      tgsub.dx=-tgsub.dx
      tgsub.crash()
    end
  elseif tgsub.dx>0 then
    tgsub.dx=limit_speed(tgsub.dx,tgsub.max_dx)
    if collide_map(tgsub,"right",0) then
      tgsub.dx=-tgsub.dx
      tgsub.crash()
    end
  end

  -- collide with player to pick up
  if (check_collision(tgsub, player.diver)) then
    player.mode = 'sub'
    player.diver_active = false
    player.diver.o2 = 60
    sfx(3)
  end

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
  if tgsub.y<world.water_surface-2 then
    tgsub.y=world.water_surface-2
  end
end

function d_sub()
  -- beforedraw()

  -- draw claw
  if (tgsub.claw_len > 0) then
    local claw_x = tgsub.x+8
    local claw_y = tgsub.y+8
    local img = 46
    if (not tgsub.claw.is_open) img=47
    line(claw_x, claw_y, claw_x, claw_y+tgsub.claw_len, 6)
    spr(img, claw_x-4, claw_y+tgsub.claw_len, 1, 1)
  end

  spr(1, tgsub.x, tgsub.y, 2, 2, tgsub.flipx)

  -- draw tgsub hitbox
  -- rect(tgsub.x, tgsub.y, tgsub.x+tgsub.w, tgsub.y+tgsub.h, 8)
  -- print("claw len: "..tgsub.claw_len, cam.x+2, cam.y+12, 8)

  -- afterdraw()
  if shake_int > 0 then shake() end
end

function limit_speed(num,maximum)
  return mid(-maximum,num,maximum)
end

-- util functions for lighting fx

-- function beforedraw()
--   -- local offset = 32
--   -- if (tgsub.flipx) then
--   --   offset = -22
--   -- end
--  myx=flr(tgsub.x+6)
--  myy=flr(tgsub.y+12)

--  myr=36
-- end
