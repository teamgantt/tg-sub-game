function i_ui()

end

function u_ui()

end

function d_ui()
  local x_off=18 --bar offsets
  local y_off=2
  local mode = tgsub.mode
  -- sub hull
  local hull_color = 11 -- good

  if (tgsub.hull < 66 and tgsub.hull > 33) then
    hull_color = 9 -- ok
  elseif(tgsub.hull < 33) then
    hull_color = 8 -- bad
  end


  -- if menu is open, draw menu
  if (tgsub.show_menu) then
    print('SELECT', tgsub.x-2, tgsub.y-8, 7)

    -- draw claw,torpedo select
    local claw_color = 9
    local torpedo_color = 9
    local diver_color = 9
    if (mode == 'claw') then
      claw_color = 11
    elseif (mode == 'torpedo') then
      torpedo_color = 11
    elseif (mode == 'diver') then
      diver_color = 11
    end
    print('TORPEDO', tgsub.x+18, tgsub.y+4, torpedo_color)
    print('CLAW', tgsub.x-18, tgsub.y+4, claw_color)
    print('DIVER', tgsub.x, tgsub.y+16, diver_color)
  end

  -- current mode
  print("mode: ❎"..player.mode, cam.x+2, cam.y+2, 9)

  if (mode == 'claw') print("CLAW: 🅾️+⬇️", cam.x+2, cam.y+8, 7)
  if (mode == 'torpedo') print("TORPEDO: 🅾️", cam.x+3, cam.y+8, 7)
  if (mode == 'diver') print("DIVER: 🅾️", cam.x+3, cam.y+8, 7)

  -- pearls
  print("X"..player.pearl, cam.x+116, cam.y+3, 9)
  spr(96, cam.x+106, cam.y+2)

  -- treasure
  print("X"..player.coin, cam.x+116, cam.y+10, 9)
  spr(61, cam.x+106, cam.y+9)

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
