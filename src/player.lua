function i_player()
  map_start=0
  map_end=256
  diver_friction=.75
  diver_gravity=0.2
  diver_jump_power=0.2
  diver_fall_gravity=0.5
  jump_boost=5
  tick=0

  walk_anim={
		f=1,
		timing=.1
	}

  player = {}
  player.pearl = 0
  player.coin = 0
  player.mode = 'sub' -- sub, diver
  player.diver_active = false
  player.diver = {}
  player.diver.jump_t = 0
  player.diver.holding_jump=false
  player.diver.jumping=false
  player.diver.walking=true
  player.diver.flipx = false
  player.diver.x = 0
  player.diver.y = 0
  player.diver.w = 0
  player.diver.h = 0
  player.diver.dx = 0
  player.diver.dy = 0
  player.diver.speed = 0.4
  player.diver.o2 = 60
  player.diver.walk_frames={4,5,6,5}
  player.diver.reset_position = function(self)
    --self=player.diver
    self.x = tgsub.x
    self.y = tgsub.y
    self.dx = 0
    self.dy = 0
    self.o2 = 60
  end

  player.diver.jump = function(self)
    self.jump_t = 30
    self.jumping = true
    diver_bubbles.step(.05)
    diver_bubbles.step(.02, 60)
    self.on_ground = false
  end

  diver_bubbles={
		elapsed=0,
		step=function(timing)
			diver_bubbles.elapsed+=timing
			if (player.diver_active and diver_bubbles.elapsed >= 1) then
				diver_bubbles.elapsed=0
        sfx(3)
        add_bubble(player.diver.x+4, player.diver.y +2,'l', rnd_between(20,60))
			end
		end
	}
end

function u_player()
  local diver = player.diver

  --apply diver_friction
  diver.dx*=diver_friction
  diver.dy*=diver_friction

  -- activate diver mode
  if (not tgsub.show_menu and tgsub.mode == 'diver' and player.mode == 'sub') then
    player.mode = 'diver'
    if (not player.diver_active) then
      -- if tile below is free, spawn diver there
      if (not collide_map({x=tgsub.x, y=tgsub.y, h=24,w=16}, 'down', 0)) then
        diver.x = tgsub.x+8
        diver.y = tgsub.y+18
      else
        diver.x = tgsub.x+18
        diver.y = tgsub.y+8
      end
    end
    player.diver_active = true
    diver.w = 8
    diver.h = 8
    diver.dx = 0
    diver.dy = 0
  end

  if (player.diver_active and player.mode == 'diver') then
    --apply controls
    if (btn(⬅️) and player.mode == 'diver') then
      diver.flipx = true
      diver.walking = true
      diver.dx-=diver.speed
      diver_bubbles.step(.045)
      sfx(1)
    end

    if (btn(➡️) and player.mode == 'diver') then
      diver.flipx = false
      diver.walking = true
      diver.dx+=diver.speed
      diver_bubbles.step(.045)
      sfx(1)
    end


    if (btn(⬇️) and not collide_map(tgsub, 'down', 0)) then
      diver.dy+=diver.speed
    end

    if (btnp(⬆️) and diver.on_ground) then
      diver:jump()
    end
  end

  -- no left or right
  if (not btn(⬅️) and not btn(➡️)) then
    diver_bubbles.step(.0055)
    diver.walking = false
  end

  -- DIVER MODE
  --animate player walk
  if walk_anim.f >= count(diver.walk_frames) then
    walk_anim.f = 1 --reset animation
  end

  if (diver.walking and diver.on_ground) then
    walk_anim.f=walk_anim.f + walk_anim.timing
  else
    walk_anim.f=1
  end

  -- apply diver movement
  if diver.dy>0 then
    diver.dy=limit_speed(diver.dy,diver.speed)

    if collide_map(diver,"down",0) then
      diver.dy=0
      diver.y-=((diver.y+diver.h+1)%8)-1
      diver.on_ground=true
    else
      diver.on_ground=false
    end
  elseif diver.dy<0 then
    if collide_map(diver,"up",0) then
      diver.dy=0
    end
  end

  -- check for collisions left and right
  if diver.dx<0 then
    diver.dx=limit_speed(diver.dx,diver.speed)
    if collide_map(diver,"left",0) then
      diver.dx=0
    end
  elseif diver.dx>0 then
    diver.dx=limit_speed(diver.dx,diver.speed)
    if collide_map(diver,"right",0) then
      diver.dx=0
    end
  end

  --apply dx and dy to player position
  diver.x+=diver.dx
  diver.y+=diver.dy

  --limit player to map
  if diver.x<map_start then
    diver.x=map_start
  end

  --limit player to map
  if diver.x>map_end-diver.w then
    diver.x=map_end-diver.w
  end

  --limit diver.y to water surface
  if diver.y<world.water_surface-2 then
    diver.y=world.water_surface-2
  end

  -- tick every 60 frames
  if (tick >= 60) then
    tick=0
  else
    tick+=1
  end

  if diver.jump_t > 0 and diver.jumping then
    diver.jump_t-=1
    diver.dy-=diver_jump_power
  else
    diver.dy+=diver_gravity
  end

  -- O2 bar updates
  if (player.diver_active) then
    -- for every second drop o2
    if (tick == 0) then
      diver.o2-=1
    end

    if (diver.o2 <= 0) then
      player.mode = 'sub'
      player.diver_active = false
      tgsub.mode = 'claw'
      diver:reset_position()
    end
  end

   -- collide with sub claw
   if (
      not tgsub.claw.is_open and
      tgsub.claw_len > 0 and
      check_collision(diver, tgsub.claw)
    ) then
    diver.is_hooked = true
    tgsub.claw.cargo = diver
  else
    diver.is_hooked = false
  end

  -- sync location with sub if not active
  if (not player.diver_active) then
    diver.x = tgsub.x
    diver.y = tgsub.y
  end

  -- if treasure is hooked, move with claw
  if (diver.is_hooked) then
    diver.x = tgsub.claw.x-4
    diver.y = tgsub.claw.y
  end
end

function d_player()
  local diver = player.diver

  if (player.diver_active) then
    if (diver.walking) then
      spr(diver.walk_frames[flr(walk_anim.f)], diver.x, diver.y, 1, 1, diver.flipx)
    elseif (diver.dy < 0) then
      spr(7, diver.x, diver.y, 1, 1, diver.flipx)
    elseif (not diver.on_ground) then
      spr(8, diver.x, diver.y, 1, 1, diver.flipx)
    else
      spr(3, diver.x, diver.y, 1, 1, diver.flipx)
    end
  end
end


function limit_speed(num,maximum)
  return mid(-maximum,num,maximum)
end
