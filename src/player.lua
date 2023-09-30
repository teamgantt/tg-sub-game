function i_player()
  map_start=0
  map_end=256
  diver_friction=.75
  diver_gravity=0.05
  diver_fall_gravity=0.5
  jump_boost=5
  tick=0

  walk_anim={
		f=1,
		timing=.1
	}

  player = {}
  player.mode = 'tgsub' -- tgsub, diver
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
  player.diver.o2 = 0
  player.diver.walk_frames={4,5,6,5}

  player.diver.jump = function(self)
    self.jump_t = 60
    self.jumping = true
    diver_bubbles.step(.05)
    diver_bubbles.step(.02, 60)
    self.on_ground = false
  end

  diver_bubbles={
		elapsed=0,
		step=function(timing)
			diver_bubbles.elapsed+=timing
			if (player.mode == 'diver' and diver_bubbles.elapsed >= 1) then
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
  if (btnp(❎) and player.mode == 'tgsub') then
    player.mode = 'diver'
    diver.x = tgsub.x+8
    diver.y = tgsub.y+16
    diver.w = 8
    diver.h = 8
    diver.dx = 0
    diver.dy = 0
    diver.o2 = 60
  elseif (btnp(❎) and player.mode == 'diver') then
    player.mode = 'tgsub'
    player.diver.o2 = 60
  end

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

  -- no left or right
  if (not btn(⬅️) and not btn(➡️)) then
    diver_bubbles.step(.0055)
    diver.walking = false
  end

	if (btn(⬇️) and not collide_map(tgsub, 'down', 0)) then
      diver.dy+=diver.speed
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
  if (btnp(⬆️) and diver.on_ground) then
    diver:jump()
  end

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


  prop_bubbles.step(.005)

  -- tick every 60 frames
  if (tick >= 60) then
    tick=0
  else
    tick+=1
  end

  if player.diver.jump_t > 0 and player.diver.jumping then
    player.diver.jump_t-=1
    player.diver.dy-=.1
  else
    player.diver.dy+=diver_gravity
  end

  -- O2 bar updates
  if (player.mode == 'diver') then
    -- for every second drop o2
    if (tick == 0) then
      player.diver.o2-=1
    end

    if (player.diver.o2 <= 0) then
      player.mode = 'tgsub'
    end
  end
end

function d_player()
  local diver = player.diver


  if (player.mode == 'diver') then
    if (diver.walking) then
      spr(diver.walk_frames[flr(walk_anim.f)], diver.x, diver.y, 1, 1, diver.flipx)
    else
      spr(3, diver.x, diver.y, 1, 1, diver.flipx)
    end

    -- print(diver.o2, diver.x-4, diver.y-8, 12)
    -- print("dx: "..diver.dx, diver.x+2, diver.y-14, 7)
    -- print("dy: "..diver.dy, diver.x+2, diver.y-6, 7)
    -- print('jump_t '..diver.jump_t, diver.x+2, diver.y-12)
    -- print('jumping: '..tostr(diver.jumping), diver.x+2, diver.y-18)
  end
end


function limit_speed(num,maximum)
  return mid(-maximum,num,maximum)
end
