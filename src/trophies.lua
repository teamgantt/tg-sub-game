function i_trophies()
  all_trophies_encoded='brute_force;for_my_aquarium;for_my_wall;and_stay_dead'
  all_trophies={}
  current_trophies={
  }

  setup_trophies=function()
    --parse all_trophies_encoded string to a data structure
    all_trophies=split(all_trophies_encoded,';')
  end

  gain_trophy=function(trophy)
    --add trophy to current_trophies
    add(current_trophies,trophy)
    sfx(13) --triumph

    -- convert trophy name to a string
    local s,t = "", split(trophy, '_')

    for i=1, #t do
      s = s..t[i].." "
    end
    display_toast(s)
  end
end
