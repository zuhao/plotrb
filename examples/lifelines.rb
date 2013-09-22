require './lib/plotrb.rb'

people = pdata.name('people').values(
  [
    {"label" => "Washington", 
    "born" => -7506057600000, 
    "died" => -5366196000000, 
    "enter" => -5701424400000, 
    "leave" => -5453884800000},
    {"label" => "Adams",    
    "born" => -7389766800000, 
    "died" => -4528285200000, 
    "enter" => -5453884800000, 
    "leave" => -5327740800000},
    {"label" => "Jefferson",  
    "born" => -7154586000000, 
    "died" => -4528285200000, 
    "enter" => -5327740800000, 
    "leave" => -5075280000000},
    {"label" => "Madison",  
    "born" => -6904544400000, 
    "died" => -4213184400000, 
    "enter" => -5075280000000, 
    "leave" => -4822819200000},
    {"label" => "Monroe",   
    "born" => -6679904400000, 
    "died" => -4370518800000, 
    "enter" => -4822819200000, 
    "leave" => -4570358400000}
  ]
)

events = pdata.name('events') do
  format(:json) { parse 'when' => :date }
  values [
    {"name" => "Decl. of Independence", "when" => "July 4, 1776"},
    {"name" => "U.S. Constitution",   "when" => "3/4/1789"},
    {"name" => "Louisiana Purchase",  "when" => "April 30, 1803"},
    {"name" => "Monroe Doctrine",     "when" => "Dec 2, 1823"}
  ]
end

y_scale = ordinal_scale.name('y').from('people.label').to_height
x_scale = time_scale.name('x').from(['people.born', 'people.died']).to_width.round.in_years

events_mark_t = text_mark.from(events) do
  enter do
    x_start { scale(x_scale).from('when') }
    y_start -10
    angle -25
    fill '#000'
    text { from 'name' }
    font 'Helvetica Neue'
    font_size 10
  end
end

events_mark_r = rect_mark.from(events) do
  enter do
    x_start { scale(x_scale).from('when') }
    y_start -8
    width 1
    height { group(:height).offset(8) }
    fill '#888'
  end
end

people_mark_t = text_mark.from(people) do
  enter do
    x_start { scale(x_scale).from('born') }
    y_start { scale(y_scale).from('label').offset(-3) }
    fill '#000'
    text { from('label') }
    font 'Helvetica Neue'
    font_size 10
  end
end

people_mark_r = rect_mark.from(people) do
  enter do
    x_start { scale(x_scale).from('born') }
    x_end { scale(x_scale).from('died') }
    y_start { scale(y_scale).from('label') }
    height 2
    fill '#557'
  end
end

people_mark_r2 = rect_mark.from(people) do
  enter do
    x_start { scale(x_scale).from('enter') }
    x_end { scale(x_scale).from('leave') }
    y_start { scale(y_scale).from('label').offset(-1) }
    height 4
    fill '#e44'
  end
end

vis = visualization.name('lifelines').width(400).height(100) do
  data people, events
  scales x_scale, y_scale
  axes x_axis.scale('x')
  marks events_mark_t, events_mark_r, people_mark_t, people_mark_r, people_mark_r2
end

puts vis.generate_spec(:pretty)