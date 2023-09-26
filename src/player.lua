function i_player()
  map_start=0
  map_end=256
	sub_gravity=0.001
  sub_friction=.98
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
  player.mode = 'sub' -- sub, diver
  player.sub = {}
  player.sub.x = 20
  player.sub.y = 220
  player.sub.w = 16
  player.sub.h = 16
  player.sub.dx = 0
  player.sub.dy = 0
  player.sub.max_dx = 0.7
  player.sub.max_dy = 0.5
  player.sub.speed = 0.5
  player.sub.flipx = false

  player.sub.hose = {
    segments={},
    length=16,
    max_length=32,
    max_segments=2,
    segment_length=8,
    segment_width=1,

    -- add a segment to the hose
    add_segment = function(self)
      local segments = self.segments
      local length = self.length
      local max_length = self.max_length
      local max_segments = self.max_segments
      local segment_length = self.segment_length
      local segment_width = self.segment_width

      -- if hose is shorter than max length, add segments
      if (length < max_length) then
        -- if hose has less than max segments, add a segment
        if (#segments < max_segments) then
          add(segments, {x=player.sub.x+8,y=player.sub.y+16,x2=player.diver.x,y2=player.diver.y})
        end
        self.length+=segment_length
      end
    end,

    -- remove a segment from the hose
    remove_segment = function(self)
      local segments = self.segments
      local length = self.length
      local max_length = self.max_length
      local max_segments = self.max_segments
      local segment_length = self.segment_length
      local segment_width = self.segment_width

      -- if hose is longer than max length, remove segments
      if (length > max_length) then
        -- if hose has more than 1 segment, remove a segment
        if (#segments > 1) then
          del(segments, segments[#segments])
        end
        self.length-=segment_length
      end
    end,

    -- update segments based on player position
    update = function(self)
      local sub = player.sub
      local hose = player.sub.hose
      local segments = hose.segments
      local length = hose.length
      local max_length = hose.max_length
      local max_segments = hose.max_segments
      local segment_length = hose.segment_length
      local segment_width = hose.segment_width

      -- if hose is longer than max length, remove segments
      if (length > max_length) then
        hose:remove_segment()
      end

      -- if hose is shorter than max length, add segments
      if (length < max_length) then
        hose:add_segment()
      end

      -- update segments
      for i=1, #segments do
        -- keep segment attached to previous segment
        if (i > 1) then
          segments[i].x = segments[i-1].x2
          segments[i].y = segments[i-1].y2
        end

        -- keep segment attached to next segment
        if (i < #segments) then
          segments[i].x2 = segments[i+1].x
          segments[i].y2 = segments[i+1].y
        end

        -- keep first segment attached to sub
        if (i == 1) then
          segments[i].x = sub.x + 8
          segments[i].y = sub.y + 8
        end

        -- keep last segment attached the diver
        if (i == #segments) then
          segments[i].x2 = player.diver.x + 4
          segments[i].y2 = player.diver.y
        end

      end
    end,
    -- remove all hose
      remove_hose = function(self)
        for i=1, #self.segments do
          del(self.segments, self.segments[#self.segments])
        end
      end
  }

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
  player.diver.o2 = 100
  player.diver.walk_frames={4,5,6,5}

  player.diver.jump = function(self)
    self.jump_t = 60
    self.jumping = true
    diver_bubbles.step(.05)
    diver_bubbles.step(.02, 60)
  end

  prop_bubbles={
		elapsed=0,
		step=function(timing)
			prop_bubbles.elapsed+=timing
			if (prop_bubbles.elapsed >= 1) then
				prop_bubbles.elapsed=0
        sfx(0)
				if player.sub.dx<0 then
          add_bubble(player.sub.x+16, player.sub.y +8,'l', rnd_between(20,40))
				else
          add_bubble(player.sub.x, player.sub.y +8,'r', rnd_between(20,40))
				end
			end
		end
	}
  diver_bubbles={
		elapsed=0,
		step=function(timing)
			diver_bubbles.elapsed+=timing
			if (diver_bubbles.elapsed >= 1) then
				diver_bubbles.elapsed=0
        sfx(3)
        add_bubble(player.diver.x+4, player.diver.y +2,'l', rnd_between(20,60))
			end
		end
	}
end

function u_player()
  local sub = player.sub
  local diver = player.diver

  --apply sub_friction
  sub.dy*=sub_friction
  sub.dx*=sub_friction

  --apply diver_friction
  diver.dx*=diver_friction
  diver.dy*=diver_friction

  -- activate diver mode
  if (btnp(❎)) then
    if (player.mode == 'sub') then
      player.mode = 'diver'
      diver.x = sub.x+8
      diver.y = sub.y+16
      diver.w = 8
      diver.h = 8
      diver.dx = 0
      diver.dy = 0
      diver.o2 = 100
    else
      player.mode = 'sub'
      diver.o2 = 100
    end
  end

  --apply controls
  if (btn(⬅️) and player.mode == 'sub') then
      sub.dx-=sub.speed
      sub.flipx = true
      sub.dy=0
      sub.dy=-sub_gravity
      prop_bubbles.step(.05)
      prop_bubbles.step(.03)
      sfx(1)
	end -- left

  if (btn(⬅️) and player.mode == 'diver') then
    diver.flipx = true
    diver.walking = true
    diver.dx-=diver.speed
    diver_bubbles.step(.045)
    sfx(1)
  end

	if (btn(➡️) and player.mode == 'sub') then
    sub.dx+=sub.speed
    sub.flipx = false
    sub.dy=-sub_gravity
    prop_bubbles.step(.05)
    prop_bubbles.step(.03)
    sfx(1)
	end -- right

  if (btn(➡️) and player.mode == 'diver') then
    diver.flipx = false
    diver.walking = true
    diver.dx+=diver.speed
    diver_bubbles.step(.045)
    sfx(1)
  end

  -- no left or right
  if (not btn(⬅️) and not btn(➡️)) then
    if (player.mode == 'diver') then
      diver_bubbles.step(.0055)
    end
    diver.walking = false
  end

	if (btn(⬇️) and not collide_map(sub, 'down', 0)) then
    if (player.mode == 'sub') then
      sub.dy+=sub.speed
      prop_bubbles.step(.03, 90)
      sfx(2)
    else
      diver.dy+=diver.speed
    end
	end

  if (btn(⬆️) and not collide_map(sub, 'up', 0)) then
    if (player.mode == 'sub') then
      sub.dy-=sub.speed
      prop_bubbles.step(.03, 90)
      sfx(2)
    end
  end

  -- SUB MODE
  -- apply sub movement
  if (player.mode == 'sub') then
    if sub.dy>0 then
      sub.dy=limit_speed(sub.dy,sub.max_dy)

      if collide_map(sub,"down",0) then
        sub.dy=0
        sub.y-=((sub.y+sub.h+1)%8)-1
      end
    elseif sub.dy<0 then
      sub.dy=limit_speed(sub.dy,sub.max_dy)
      if collide_map(sub,"up",0) then
        sub.dy=0
      end
    end

    -- check for collisions left and right
    if sub.dx<0 then
      sub.dx=limit_speed(sub.dx,sub.max_dx)
      if collide_map(sub,"left",0) then
        sub.dx=0
      end
    elseif sub.dx>0 then
      sub.dx=limit_speed(sub.dx,sub.max_dx)
      if collide_map(sub,"right",0) then
        sub.dx=0
      end
    end

    --apply dx and dy to player position
    sub.x+=sub.dx
    sub.y+=sub.dy

    --limit player to map
    if sub.x<map_start then
      sub.x=map_start
    end

    --limit player to map
    if sub.x>map_end-sub.w then
      sub.x=map_end-sub.w
    end

    --limit sub.y to water surface
    if sub.y<world.water_surface-2 then
      sub.y=world.water_surface-2
    end
  else
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
  end

  limit_speed(sub.dx, sub.max_dx)
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
    diver.dy+=diver_gravity
  end

  -- O2 bar updates
  if (player.mode == 'diver') then
    -- for every second drop o2
    if (tick == 0) then
      diver.o2-=1
    end

    if (diver.o2 <= 0) then
      player.mode = 'sub'
    end
  end

  -- update hose
  if (player.mode == 'sub') then
    player.sub.hose:remove_hose()
  else
    player.sub.hose:update()
  end
end

function d_player()
  beforedraw()
  local sub = player.sub
  local diver = player.diver
  spr(1, sub.x, sub.y, 2, 2, sub.flipx)

  if (player.mode == 'diver') then
    -- print(diver.o2, diver.x-4, diver.y-8, 12)

    if (diver.walking) then
      spr(diver.walk_frames[flr(walk_anim.f)], diver.x, diver.y, 1, 1, diver.flipx)
    else
      spr(3, diver.x, diver.y, 1, 1, diver.flipx)
    end
    -- print("dx: "..diver.dx, diver.x+2, diver.y-14, 7)
    -- print("dy: "..diver.dy, diver.x+2, diver.y-6, 7)
    -- print('jump_t '..diver.jump_t, diver.x+2, diver.y-12)
    print('jumping: '..tostr(diver.jumping), diver.x+2, diver.y-18)
    print('hoses: '..#player.sub.hose.segments, diver.x+2, diver.y-2, 11)
  end


  -- draw hose
  local segments = player.sub.hose.segments
  for i=1, #segments do
    local segment = segments[i]
    line(segment.x, segment.y, segment.x2, segment.y2, 6)
  end

  afterdraw()
end


function limit_speed(num,maximum)
  return mid(-maximum,num,maximum)
end



drawmybg=false

function beforedraw()
  -- local offset = 32
  -- if (player.sub.flipx) then
  --   offset = -22
  -- end
 myx=flr(player.sub.x+6)
 myy=flr(player.sub.y+12)

 myr=36

--  stop('myx'..myx..' myy'..myy..' myr'..myr, 20, 20, 7)
 --clip(myx-myr,myy-myr,myr*2+1,myr*2+1)
end

function afterdraw()
 --copy the sccreen to the
 --spritesheet
  memcpy(0,0x6000,0x2000)

  --remap spritesheet to become
  --the screen
  poke2(0x5f55,0)

  fillp(0B1111010111110101.110)
  -- circfill(myx,myy,myr+4,3)
  circfill(myx,myy,myr+10,0)
  fillp()
  circfill(myx,myy,myr,0)
  fillp(0XFDF5)
  circfill(myx,myy,myr+2,0)
  fillp()


  --  --video remapping back to norma
  poke(0x5f55,0x60)

  --  --set white to transparent
  palt(7,true)

  --  --shift colors darker
  pal({0,1,1,2,0,5,5,2,5,13,3,1,1,2,13})

  --  --draw the entire spritesheet to the screen
  sspr(0,0,128,128,cam.x,cam.y)

  --reset everything
  reload(0,0,0x2000)
  palt()
  pal()
end


--helper wrapper for sspr that
--allows us to conveniently
--change a line function into
--an sspr function
  function ssprline(x1,y1,x2,y2)
    sspr(x1,y1,1,y2-y1,x1,y1)
   end
