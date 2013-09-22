require './lib/plotrb.rb'

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

xs = linear_scale.name('x').from('table.x').to_width.exclude_zero
ys = linear_scale.name('y').from('table.y').to_height.nicely

xa = x_axis.scale(xs).ticks(20)
ya = y_axis.scale(ys)

mark = area_mark.from(data) do
	enter do
		interpolate :monotone
		x_start {from('x').scale(xs)}
		y_start {from('y').scale(ys)}
		y_end {value(0).scale(ys)}
		fill 'steelblue'
	end
	update do
		fill_opacity 1
	end
	hover do
		fill_opacity 0.5
	end
end

vis = visualization.name('area').width(500).height(200) do
	padding :top => 10, :left => 30, :bottom => 30, :right => 10
	data data
	scales xs, ys
	axes xa, ya
	marks mark
end

puts vis.generate_spec(:pretty)
