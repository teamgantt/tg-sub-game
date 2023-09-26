
function i_particles()
  --particles
  bubbles = {}
  bubble_life=40
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
end

function d_particles()
  for fx in all(bubbles) do
    local x=fx.x
    local y=fx.y

    -- bubbles shrink as they get older
    local s=1
    local c=7

    -- if fx.t>fx.life/4 then
    --   s=2
    --   c=7
    -- end
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

    -- if (fx.t > bubble_life-10) then
    --   pset(x,y,7)
    -- elseif (fx.t > bubble_life-20 and fx.t < bubble_life-10) then
    --   circ(x,y,3,7)
    -- elseif (fx.t < bubble_life) then
    --   circ(x,y,2,6)
    -- elseif (fx.t < bubble_life*.33) then
    --   circ(x,y,1,5)
    -- end

  end
end

