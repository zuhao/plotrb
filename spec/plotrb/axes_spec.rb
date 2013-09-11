require_relative '../spec_helper'

describe 'Axis' do

  subject { ::Plotrb::Axis.new(:x) }

  describe '#type' do

    it 'raises error if type is neither x or y' do
      subject.instance_variable_set(:@type, :foo)
      expect { subject.send(:process_type) }.to raise_error(ArgumentError)
    end

  end

  describe '#scale' do

    it 'sets the scale backing the axis by name' do
      subject.from('foo_scale')
      subject.scale.should == 'foo_scale'
    end

    it 'sets the scale backing the axis by the scale object' do
      scale = ::Plotrb::Scale.new.name('foo_scale')
      subject.from(scale)
      subject.send(:process_scale)
      subject.scale.should == 'foo_scale'
    end

    it 'raises error if scale is not found' do
      subject.from('foo_scale')
      ::Plotrb::Kernel.stub(:find_scale).and_return(nil)
      expect { subject.send(:process_scale) }.to raise_error(ArgumentError)
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

  end

  describe '#title_offset' do

    it 'sets offset of the title' do
      subject.offset_title_by(5)
      subject.title_offset.should == 5
    end

  end

  describe 'format' do

    it 'accepts valid format specifier' do
      subject.format('04d')
      expect { subject.send(:process_format) }.to_not raise_error(ArgumentError)
    end

    it 'raises error if format specifier is invalid' do
      subject.format('{$s04d,g')
      expect { subject.send(:process_format) }.to raise_error(ArgumentError)
    end

  end

  describe '#ticks' do

    it 'sets ticks of the axis' do
      subject.with_20_ticks
      subject.ticks.should == 20
    end

  end

  describe '#values' do

    it 'sets values if given as an array' do
      subject.values([1,2,3,4])
      subject.values.should match_array([1,2,3,4])
    end

    it 'sets values if given one by one as arguments' do
      subject.values(1,2,3,4)
      subject.values.should match_array([1,2,3,4])
    end

  end

  describe '#subdivide' do

    it 'sets subdivide of the ticks' do
      subject.subdivide_by(10)
      subject.subdivide.should == 10
    end

  end

  describe '#tick_padding' do

    it 'sets padding for the ticks' do
      subject.tick_padding(5)
      subject.tick_padding.should == 5
    end

  end

  describe '#tick_size' do

    it 'sets size for the ticks' do
      subject.tick_size(5)
      subject.tick_size.should == 5
    end

  end

  describe '#tick_size_major' do

    it 'sets major tick size' do
      subject.major_tick_size(10)
      subject.tick_size_major.should == 10
    end

  end

  describe '#tick_size_minor' do

    it 'sets minor tick size' do
      subject.minor_tick_size(10)
      subject.tick_size_minor.should == 10
    end

  end

  describe '#tick_size_end' do

    it 'sets end tick size' do
      subject.end_tick_size(10)
      subject.tick_size_end.should == 10
    end

  end

  describe '#offset' do

    it 'sets offset of the axis' do
      subject.offset_by(10)
      subject.offset.should == 10
    end

  end

  describe '#layer' do

    it 'sets the layer of the axis' do
      subject.in_front
      subject.layer.should == :front
    end

  end

  describe 'above' do

    it 'sets the layer to front' do
      subject.above
      subject.layer.should == :front
      subject.above?.should be_true
    end

  end

  describe 'below' do

    it 'sets the layer to back' do
      subject.below
      subject.layer.should == :back
      subject.below?.should be_true
    end

  end

  describe '#grid' do

    it 'sets if grid-lines should be shown' do
      subject.show_grid
      subject.grid?.should be_true
    end

  end

  describe '#method_missing' do

    it 'sets ticks if in_some_ticks is called' do
      subject.with_20_ticks
      subject.ticks.should == 20
    end

    it 'sets subdivide if subdivide_by_some is called' do
      subject.subdivide_by_10
      subject.subdivide.should == 10
    end

    it 'sets orient if at_orient_position is called' do
      subject.at_bottom
      subject.orient.should == :bottom
    end

    it 'sets layer if at_layer_position is called' do
      subject.in_front
      subject.layer.should == :front
    end

  end

end
