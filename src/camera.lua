function i_camera()
	cam={x=0,y=0}
  --map limits
  map_start=0
  map_end=1024
end

function u_camera()
  if (player.mode == 'sub') then
    cam.x=player.sub.x-60
    cam.y=player.sub.y-60
  else
    cam.x=player.diver.x-60
    cam.y=player.diver.y-60
  end

	cam.x=mid(map_start, cam.x,map_end)
	cam.y=mid(map_start, cam.y,1024)

	camera(cam.x, cam.y)
end
