function i_ui()
  toast_t=0
  toast_text='brute force'
  toast_y=128
  display_toast = function(text)
    toast_t = 120
    toast_text = text
  end
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
  print("mode: ❎"..player.mode, cam_x+2, cam_y+2, 9)

  if (mode == 'claw') print("CLAW: 🅾️+⬇️", cam_x+2, cam_y+8, 7)
  if (mode == 'torpedo') print("TORPEDO: 🅾️", cam_x+3, cam_y+8, 7)
  if (mode == 'diver') print("DIVER: 🅾️", cam_x+3, cam_y+8, 7)

  -- pearls
  print("X"..player.pearl, cam_x+116, cam_y+3, 9)
  spr(96, cam_x+106, cam_y+2)

  -- treasure
  print("X"..player.coin, cam_x+116, cam_y+10, 9)
  spr(61, cam_x+106, cam_y+9)

  -- hull
  print('HULL', cam_x+2, cam_y+120, 10)
  line(cam_x+2+x_off, cam_y+121+y_off, cam_x+tgsub.hull+x_off, cam_y+121+y_off, hull_color)
  rect(cam_x+2+x_off, cam_y+120+y_off, cam_x+100+x_off, cam_y+122+y_off, 7)

  if (player.diver_active) then
    -- diver o2
    print('AIR', cam_x+2, cam_y+115, 12)
    line(cam_x+3+x_off, cam_y+116+y_off, cam_x+player.diver.o2+x_off, cam_y+116+y_off, 12)
    rect(cam_x+2+x_off, cam_y+115+y_off, cam_x+60+x_off, cam_y+117+y_off, 7)
  end

  if (toast_t > 0) then
    -- slide in
    if (toast_y > 0) then
      if (toast_y>124) toast_y-=.5
    end
    rectfill(cam_x, cam_y+toast_y-12, cam_x+128, cam_y+toast_y, 0)
    spr(117, cam_x+3, cam_y+toast_y-10)
    print(toast_text, cam_x+14, cam_y+toast_y-8, 7)
    toast_t = toast_t - 1
  end
end
