function dst(o1,o2)
  return sqrt(sqr(o1.x-o2.x)+sqr(o1.y-o2.y))
 end

function sqr(x) return x*x end

function indexof(tbl, val)
  for i,v in pairs(tbl) do
    if v == val then
      return i
    end
  end
end

function limit_speed(num,maximum)
  return mid(-maximum,num,maximum)
end

