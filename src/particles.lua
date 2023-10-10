
function i_particles()
  --particles
  bubbles = {}
  chunks = {}
  sparks = {}
  bubble_life=40
  spark_life=20
  add_bubble = function (x,y,dir,life)
    local fx={
        x=x,
        y=y-flr(rnd(4)),
        t=0,
        dx=0,
        life=life or bubble_life,
        dy=.4,
        dir=dir,
    }
    if (dir=='l') fx.dx=.4
    if (dir=='r') fx.dx=-.4

    add(bubbles,fx)
  end

  add_explosion = function (x,y,life)
    for i=1,6 do
      add_bubble(x,y, nil, life) -- no dir
    end
  end

  breakup = function (x,y,color)
    for i=1,4 do
      add(chunks, {
        x=x,
        y=y,
        t=0,
        c=color,
        -- dx and dy are random in both directions
        dx=rnd(1)-.5/i,
        dy=rnd(1)-.5/i,
        life=spark_life,
      }) -- no dir
    end
  end

  add_sparks = function (x,y,dir, life)
    local fx={
      x=x,
      y=y-flr(rnd(4)),
      t=0,
      dx=flr(rnd(2)),
      dy=0.2,
      life=life or spark_life,
      dy=0.4,
      dir=dir,
    }
    if (dir) then
      if (dir=='l') fx.dx=.4
      if (dir=='r') fx.dx=-.4
    else
      fx.dx = rnd(1)
    end


    add(sparks, fx)
  end
end


function u_particles()
  for fx in all(bubbles) do
      --lifetime
      fx.t+=1

      if fx.t>fx.life/3 then
        fx.dy=.2
        fx.dx=0
      end
      if fx.t>fx.life then del(bubbles,fx) end

      --move
      fx.y-=fx.dy
      fx.x+=fx.dx
  end

  for fx in all(sparks) do
    --lifetime
    fx.t+=1
    if fx.t>fx.life then del(sparks,fx) end

    --move
    fx.y+=fx.dy
    fx.x+=fx.dx
  end

  for fx in all(chunks) do
    --lifetime
    fx.t+=1
    if fx.t>fx.life then del(chunks,fx) end

    --move
    fx.y+=fx.dy
    fx.x+=fx.dx
  end
end

function d_particles()
  for fx in all(bubbles) do
    local x=fx.x
    local y=fx.y

    -- bubbles shrink as they get older
    local s=1
    local c=7

    if fx.t>fx.life/3 then
      s=2
      c=7
    end
    if fx.t>fx.life/2 then
      s=1
      c=6
    end

    -- draw bubble
    circ(x,y,s,c)
  end

  for fx in all(sparks) do
    local x=fx.x
    local y=fx.y

    local c=10
    -- draw spark
    pset(x,y,c)
  end

  for fx in all(chunks) do
    local x=fx.x
    local y=fx.y
    -- draw spark
    rectfill(x,y,x+2,y+2,fx.c)
  end
end

