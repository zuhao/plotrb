require 'plotrb'

data = pdata.name('table').values(
    [
      {x: 1,  y: 28}, {x: 2,  y: 55},
      {x: 3,  y: 43}, {x: 4,  y: 91},
      {x: 5,  y: 81}, {x: 6,  y: 53},
      {x: 7,  y: 19}, {x: 8,  y: 87},
      {x: 9,  y: 52}, {x: 10, y: 48},
      {x: 11, y: 24}, {x: 12, y: 49},
      {x: 13, y: 87}, {x: 14, y: 66},
      {x: 15, y: 17}, {x: 16, y: 27},
      {x: 17, y: 68}, {x: 18, y: 16},
      {x: 19, y: 49}, {x: 20, y: 15}
    ]
)

xs = ordinal_scale.name('x').from('table.x').to_width
ys = linear_scale.name('y').from('table.y').nicely.to_height

mark = rect_mark.from(data) do
  enter do
    x_start   { scale(xs).from('x') }
    width     { scale(xs).offset(-1).use_band }
    y_start   { scale(ys).from('y') }
    y_end     { scale(ys).value(0) }
  end
  update do
    fill 'steelblue'
  end
  hover do
    fill 'red'
  end
end

vis = visualization.width(400).height(200) do
  padding top: 10, left: 30, bottom: 30, right: 10
  data data
  scales xs, ys
  marks mark
  axes x_axis.scale(xs), y_axis.scale(ys)
end

puts vis.generate_spec(:pretty)
