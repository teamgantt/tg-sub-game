function i_trophies()
  all_trophies_encoded='brute_force;for_my_aquarium;for_my_wall;and_stay_dead;no_sushi_tonight;catch_and_release;super_wrangler;repair_man;the_claaaw;one_small_step;you_raise_me_up;crab_n_go;super_surfer;fresh_air;found_nemo;captain_planet;pearl_necklace;fat_wallet;tool_collector;et_tu_brute'
  all_trophies={}
  current_trophies={
  }

  all_trophies=split(all_trophies_encoded,';')

  -- load trophies from save data
  for i,v in pairs(all_trophies) do
    local t = dget(i)
    if t > 0 then
      add(current_trophies, all_trophies[i])
      -- printh('loaded trophy '..all_trophies[i], 'log')
    end
  end

  save_trophy=function(trophy)
    --add trophy to save data
    local i = indexof(all_trophies, trophy)
    dset(i, 1)
  end

  gain_trophy=function(trophy)
    --add trophy to current_trophies

    -- return if already gained
    local cur_trophy = indexof(current_trophies, trophy)
    if cur_trophy and cur_trophy > 0 then
      return
    end

    add(current_trophies,trophy)
    sfx(13) --triumph

    save_trophy(trophy)

    -- convert trophy name to a string
    local s,t = "", split(trophy, '_')

    for i=1, #t do
      s = s..t[i].." "
    end
    display_toast(s)
  end

  -- printh('trophies loaded;;;;;;', 'log')
end
