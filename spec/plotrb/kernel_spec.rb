require_relative '../spec_helper'

describe 'Kernel' do

  class Object
    include ::Plotrb::Kernel
  end

  describe '#visualization' do

    it 'creates new visualization object' do
      v = visualization
      v.is_a?(::Plotrb::Visualization).should be_true
    end

  end

  describe '#pdata' do

    it 'creates new data object' do
      d = pdata
      d.is_a?(::Plotrb::Data).should be_true
    end

  end

  describe '#method_missing' do

    it 'creates axis object' do
      a = x_axis
      a.is_a?(::Plotrb::Axis).should be_true
      a.type.should == :x
    end

    it 'creates scale object' do
      s = linear_scale
      s.is_a?(::Plotrb::Scale).should be_true
      s.type.should == :linear
    end

    it 'creates mark object' do
      m = rect_mark
      m.is_a?(::Plotrb::Mark).should be_true
      m.type.should == :rect
    end

    it 'creates transform object' do
      t = filter_transform
      t.is_a?(::Plotrb::Transform).should be_true
      t.type.should == :filter
    end
  end

end
