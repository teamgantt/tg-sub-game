
function i_world()
  world={}
  world.water_surface=28
  world.chests={}
  world.clams={}
  world.shark={}
  world.fish={}
  world.treasures={}


  -- setup dynamic objects
  -- loop over all map tiles and create objects
  for i=1, 208 do
    for j=1, 256 do
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
        add(world.fish, f)
        -- remove static tile
        mset(i, j, 0)
      end
    end
  end
end

function u_world()
  -- update sharks
  for i=1, #world.shark do
    if (world.shark[i] != nil) world.shark[i]:update()
  end

  -- update dynamic objects
  for i=1, #world.chests do
    if (world.chests[i] != nil) world.chests[i]:update()
  end

  for i=1, #world.clams do
    if (world.clams[i] != nil) world.clams[i]:update()
  end

  -- update treasures
  for i=1, #world.treasures do
    if (world.treasures[i] != nil) world.treasures[i]:update()
  end

  -- updating fish
  for i=1, #world.fish do
    if (world.fish[i] != nil) world.fish[i]:update()
  end

  -- maintain sharks
  if (#world.shark < 4) then
    local shark = shark(rnd_between(0, 208)*8, rnd_between(0, 256)*8)
    add(world.shark, shark)
  end

  -- maintain fish
  if (#world.fish < 4) then
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

  -- draw sharks
  for i=1, #world.shark do
    world.shark[i]:draw()
  end
  -- draw dynamic objects
  for i=1, #world.chests do
    world.chests[i]:draw()
  end
  for i=1, #world.clams do
    world.clams[i]:draw()
  end

  -- draw treasures
  for i=1, #world.treasures do
    world.treasures[i]:draw()
  end

  -- draw fish
  for i=1, #world.fish do
    world.fish[i]:draw()
  end
end


function rnd_between(min, max)
	return flr(rnd(max-min+1))+min
end
