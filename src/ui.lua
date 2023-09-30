function i_ui()

end

function u_ui()

end

function d_ui()
  -- sub hull
  print('hull', cam.x+2, cam.y+107, 7)
  local hull_color = 11 -- good

  if (tgsub.hull < 66 and tgsub.hull > 33) then
    hull_color = 9 -- ok
  elseif(tgsub.hull < 33) then
    hull_color = 8 -- bad
  end

  line(cam.x+2, cam.y+114, cam.x+tgsub.hull, cam.y+114, hull_color)
  rect(cam.x+2, cam.y+113, cam.x+100, cam.y+115, 7)

  if (player.mode == 'diver') then
    -- diver o2
    print('o2', cam.x+2, cam.y+118, 7)

    line(cam.x+12, cam.y+121, cam.x+player.diver.o2, cam.y+121, 12)
    rect(cam.x+12, cam.y+120, cam.x+60, cam.y+122, 7)
    -- rectfill(cam.x+12, cam.y+120, cam.x+player.diver.o2, cam.y+122, 12)
  end
end
