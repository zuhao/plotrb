require './lib/plotrb.rb'

ump_data = pdata.name('unemp') do
	url('unemployment.tsv')
	format(:tsv) { parse :rate => :number }
end
cty_data = pdata.name('counties') do
	url('us-10m.json')
	format(:topojson) { feature 'counties' }
	transform [
		geopath_transform.projection(:albersUsa),
		zip_transform.with('unemp').match('id').against('id').as('value').default(nil),
		filter_transform.test('d.path!=null && d.value!=null')
	]
end

cs = quantize_scale.name('color').from([0, 0.15]).to(
	[
		"#f7fbff",
    "#deebf7",
    "#c6dbef",
    "#9ecae1",
    "#6baed6",
    "#4292c6",
    "#2171b5",
    "#08519c",
    "#08306b"
  ])

mark = path_mark.from(cty_data) do
	enter do
		path { from 'path' }
	end
	update do
		fill { scale(cs).from('value.data.rate') }
	end
	hover do
		fill 'red'
	end
end

vis = visualization.width(960).height(500) do
	data ump_data, cty_data
	scales cs
	marks mark
end

puts vis.generate_spec(:pretty)
