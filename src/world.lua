
function i_world()
  world={}
  world.water_surface=28
  world.chests={}
  world.clams={}
  world.sharks={}
  world.treasures={}

  shark1 = shark(160, 160)
  shark2 = shark(280, 180)

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
    end
  end
end

function u_world()
  -- update sharks
  shark1:update()
  shark2:update()

  -- update dynamic objects
  for i=1, #world.chests do
    world.chests[i]:update()
  end

  for i=1, #world.clams do
    world.clams[i]:update()
  end

  -- update treasures
  for i=1, #world.treasures do
    world.treasures[i]:update()
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
  shark1:draw()
  shark2:draw()

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

end


function rnd_between(min, max)
	return flr(rnd(max-min+1))+min
end
