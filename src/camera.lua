function i_camera()
	cam={x=0,y=0}
  --map limits
  map_start=0
  map_end=1024

  shake = function()
    -- stop('shake '..shake_int, 20, 20, 11)
    local shake_x=rnd(shake_int) - (shake_int /3)
    local shake_y=rnd(shake_int) - (shake_int /3)

    --offset the camera
    camera(cam.x+shake_x, cam.y+shake_y)

    --ease shake and return to normal
    shake_int *= .9
    if shake_int < .4 then shake_int = 0 end
  end

end

function u_camera()
end
