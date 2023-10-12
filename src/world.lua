
function i_world()
  wave_timing = 0.075
  wave_frames={99,100,101,102}
  map_cell_w = 128
  map_cell_h = 63

  world={
    chests={},
    clams={},
    treasures={},
    fish={},
    crab={},
    waves={},
    shark={},
    water_surface=31
  }



  -- setup dynamic objects
  -- loop over all map tiles and create objects
  replace_tiles(59, function(x,y) add(world.chests, chest(x,y)) end)
  replace_tiles(11, function(x,y) add(world.clams, clam(x,y)) end)
  replace_tiles(80, function(x,y) add(world.fish, fish(x,y)) end)
  replace_tiles(68, function(x,y) add(world.shark, shark(x,y)) end)
  replace_tiles(86, function(x,y) add(world.crab, crab(x,y)) end)
  replace_tiles(99, function(x,y) add(world.waves, {
    x=x,
    y=y,
    fr=1,
    update=function(self, frame_count)
      self.fr += wave_timing
      if (self.fr >= 4) then
        self.fr = 1
      end
    end;
    draw=function(self)
      spr(wave_frames[flr(self.fr)+1], self.x, self.y)
    end
  }) end)
  -- add one-off grabbables
  add(world.treasures, treasure('alien',456,496))
  add(world.treasures, treasure('nemo',904,160))
  add(world.treasures, treasure('bottle',104,480))
end

function u_world()
  foreach(world.waves, guarded_update)
  foreach(world.shark, guarded_update)
  foreach(world.chests, guarded_update)
  foreach(world.clams, guarded_update)
  foreach(world.crab, guarded_update)
  foreach(world.treasures, guarded_update)
  foreach(world.fish, guarded_update)

  -- maintain shark
  if (#world.shark < 2) then
    -- attempt to spawn a shark
    local x,y = rnd_between(0, 128)*8, rnd_between(0, 128)*8
    -- only spawn shark if not on a tile with flag 0
    if (fget(mget(x/8,y/8), 0) == false) then
      local shark = shark(x,y)
      add(world.shark, shark)
    end
  end

  -- -- maintain fish
  if (#world.fish < 10) then
    local f = fish(rnd_between(0, 128)*8, rnd_between(0, 128)*8)
    add(world.fish, f)
  end
end

function d_world()
  cls(1)
  rectfill(0,0,1024,world.water_surface,12) --sky

  map(0,0,0,0,128,64)

  foreach(world.waves, draw_obj)

  -- draw shark'
  foreach(world.shark, draw_obj)

  -- draw dynamic objects
  foreach(world.chests, draw_obj)
  foreach(world.clams, draw_obj)

  -- draw treasures
  foreach(world.treasures, draw_obj)

  -- draw fish
  foreach(world.fish, draw_obj)

  -- draw crab
  foreach(world.crab, draw_obj)

  -- print('fish: '..#world.fish, cam_x+30, cam_y+20, 7)
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

function replace_tiles(tile_to_replace, new_obj)
  for cell_x=0,map_cell_w-1 do
    for cell_y=0,map_cell_h-1 do
      local tile = mget(cell_x,cell_y)
      if tile == tile_to_replace then
        -- Remove tile
        mset(cell_x,cell_y,0)
        -- Create sprite
        new_obj(cell_x*8,cell_y*8)
      end
    end
  end
end
