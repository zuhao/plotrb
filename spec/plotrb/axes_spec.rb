require_relative '../spec_helper'

describe 'Axis' do

  subject { ::Plotrb::Axis.new(type: :x) }

  describe '#from' do

    it 'sets the scale backing the axis by name' do
      subject.from('foo_scale')
      subject.scale.should == 'foo_scale'
    end

    it 'sets the scale backing the axis by the scale object' do
      scale = ::Plotrb::Scale.new(name: 'foo_scale')
      subject.from(scale)
      subject.scale.should == 'foo_scale'
    end

  end

  describe '#orient' do

    it 'sets the orient of the axis' do
      subject.at_bottom
      subject.orient.should == :bottom
    end

  end

  describe '#title' do

    it 'sets title of the axis' do
      subject.title('foo')
      subject.title.should == 'foo'
    end

    it 'sets title and offset of the axis' do
      subject.title('foo', 5)
      subject.title.should == 'foo'
      subject.title_offset.should == 5
    end

  end

  describe '#offset_title_by' do

    it 'sets offset of the title' do
      subject.offset_title_by(5)
      subject.title_offset.should == 5
    end

  end

  describe '#ticks' do

    it 'sets ticks of the axis' do
      subject.in_20_ticks
      subject.ticks.should == 20
    end

  end

  it 'sets subdivide of the ticks' do
    subject.subdivide_by(10)
    subject.subdivide.should == 10
  end

  it 'sets major tick size' do
    subject.major_tick_size(10)
    subject.tick_size_major.should == 10
  end

  it 'sets minor tick size' do
    subject.minor_tick_size(10)
    subject.tick_size_minor.should == 10
  end

  it 'sets end tick size' do
    subject.end_tick_size(10)
    subject.tick_size_end.should == 10
  end

  it 'sets offset of the axis' do
    subject.offset_by(10)
    subject.offset.should == 10
  end

  it 'sets the layer of the axis' do
    subject.at_front
    subject.layer.should == :front
  end

  it 'sets if gridlines should be shown' do
    subject.show_grid
    subject.grid?.should be_true
  end

end
