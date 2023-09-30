
function i_world()
  world={}
  world.water_surface=28

  shark1 = shark(50, 160)
end

function u_world()
  -- update sharks
  shark1:update()
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
end


function rnd_between(min, max)
	return flr(rnd(max-min+1))+min
end
