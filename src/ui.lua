function i_ui()

end

function u_ui()

end

function d_ui()
  if (player.mode == 'diver') then
    print('o2', cam.x+2, cam.y+118, 7)
    rectfill(cam.x+12, cam.y+120, cam.x+player.diver.o2, cam.y+122, 12)
  end
end
