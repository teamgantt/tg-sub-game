
function i_world()
  wave_timing = 0.075
  wave_frames={99,100,101,102}
  world={
    water_surface=31,
    chests={},
    clams={},
    shark={},
    fish={},
    treasures={},
    waves={}
  }


  -- setup dynamic objects
  -- loop over all map tiles and create objects
  for i=1, 128 do
    for j=1, 128 do
      local tile = mget(i, j)
      if tile == 59 then
        -- create a chest
        local chest = chest(i*8, j*8)
        add(world.chests, chest)
        -- remove static tile
        mset(i, j, 0)
      end

      if tile == 11 then
        -- create a clam
        local clam = clam(i*8, j*8)
        add(world.clams, clam)
        -- remove static tile
        mset(i, j, 0)
      end

      if tile == 68 then
        -- create a shark
        local shark = shark(i*8, j*8)
        add(world.shark, shark)
        -- remove static tile
        mset(i, j, 0)
      end

      if tile == 80 then
        -- create a treasure
        local f = fish(i*8, j*8)
        add(world.fish,  f)
        -- remove static tile
        mset(i, j, 0)
      end

      if tile==99 then
        -- add wave
        add(world.waves, {
          x=i*8,
          y=j*8,
          fr=1,
          update=function(self)
            self.fr += wave_timing
            if (self.fr > #wave_frames) then
              self.fr = 1
            end
          end;
          draw=function(self)
            spr(wave_frames[flr(self.fr)], self.x, self.y)
          end
        })
        -- remove static tile
        mset(i, j, 0)
      end
    end
  end
end

function u_world()
  -- update waves
  foreach(world.waves, guarded_update)

  -- update sharks
  foreach(world.shark, guarded_update)
  -- update dynamic objects
  foreach(world.chests, guarded_update)
  foreach(world.clams, guarded_update)
  -- update treasures
  foreach(world.treasures, guarded_update)
  -- update fish
  foreach(world.fish, guarded_update)


  -- maintain sharks
  if (#world.shark < 4) then
    local shark = shark(rnd_between(0, 208)*8, rnd_between(0, 256)*8)
    add(world.shark, shark)
  end

  -- maintain fish
  if (#world.fish < 5) then
    local f = fish(rnd_between(0, 208)*8, rnd_between(0, 256)*8)
    add(world.fish, f)
  end
end

function d_world()
  cls(1)
  rectfill(0,0,1024,world.water_surface,12) --sky
  map(96,27,0,208,128)
  map(96,27,0+16,208,128)
  map(96,27,0+64,232,128)

  for i=1, 16 do
    map(96,27,0+(i*32),208,128)
  end

  map(0,0,0,0, 128, 256)

  foreach(world.waves, draw_obj)

  -- draw sharks'
  foreach(world.shark, draw_obj)

  -- draw dynamic objects
  foreach(world.chests, draw_obj)
  foreach(world.clams, draw_obj)

  -- draw treasures
  foreach(world.treasures, draw_obj)

  -- draw fish
  foreach(world.fish, draw_obj)
end


function rnd_between(min, max)
	return flr(rnd(max-min+1))+min
end

function guarded_update(thing)
  if (thing != nil) thing:update()
end

function draw_obj(obj)
  if (obj != nil) obj:draw()
end
