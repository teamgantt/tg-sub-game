function i_ui()

end

function u_ui()

end

function d_ui()
  local x_off=18 --bar offsets
  local y_off=2
  -- sub hull
  local hull_color = 11 -- good

  if (tgsub.hull < 66 and tgsub.hull > 33) then
    hull_color = 9 -- ok
  elseif(tgsub.hull < 33) then
    hull_color = 8 -- bad
  end

  -- hull
  print('HULL', cam.x+2, cam.y+120, 10)
  line(cam.x+2+x_off, cam.y+121+y_off, cam.x+tgsub.hull+x_off, cam.y+121+y_off, hull_color)
  rect(cam.x+2+x_off, cam.y+120+y_off, cam.x+100+x_off, cam.y+122+y_off, 7)

  if (player.diver_active) then
    -- diver o2
    print('AIR', cam.x+2, cam.y+115, 12)
    line(cam.x+3+x_off, cam.y+116+y_off, cam.x+player.diver.o2+x_off, cam.y+116+y_off, 12)
    rect(cam.x+2+x_off, cam.y+115+y_off, cam.x+60+x_off, cam.y+117+y_off, 7)
  end
end
