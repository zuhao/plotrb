require './lib/plotrb.rb'

raw_data = pdata.name('barley').url('barley_data.json')
variety = pdata.name('variety').source('barley').transform [
	facet_transform.keys('variety'),
	stats_transform.value('yield').median,
	sort_transform.by('-median')
]
site = pdata.name('site').source('barley').transform [
	facet_transform.keys('site'),
	stats_transform.value('yield').median,
	sort_transform.by('-median')
]

gs = ordinal_scale.name('g').padding(0.15).from('site.key').to_height
xs = linear_scale.name('x').from('barley.yield').to_width.nicely
cs = ordinal_scale.name('c').to_colors
ys = ordinal_scale.name('y').from('variety.key').to_height.as_points.padding(1.2)
xaxis = x_axis.scale(xs).offset(-12)
yaxis = y_axis.scale(ys).tick_size(0) do
  properties(:axis) { stroke :transparent }
end


tm = text_mark.from(site) do
  enter do
    x { group(:width).times(0.5) }
    y { scale(gs).field(:key).offset(-2) }
    font_weight :bold
    text { field(:key) }
    align :center
    baseline :bottom
    fill '#000'
  end
end

sm = symbol_mark.enter do
  x { scale(xs).field('yield') }
  y { scale(ys).field('variety') }
  size 50
  stroke { scale(cs).field('year') }
  stroke_width 2
end

gm = group_mark.from(site) do
  scales ys
  axes yaxis
  marks sm
  enter do
    x 0.5
    y { scale(gs).field(:key) }
    height { scale(gs).use_band }
    width { group(:width) }
    stroke '#ccc'
  end
end

vis = visualization.width(200).height(720) do
  data raw_data, variety, site
  scales gs, cs, xs, ys
  axes xaxis
  marks tm, gm
end

puts vis.generate_spec(:pretty)

