require_relative '../spec_helper'
require_relative '../../lib/plotrb/visualization'

describe 'Visualization' do

  context 'properties' do

    before(:each) do
      @vis = ::Plotrb::Visualization.new
    end

    it 'sets name' do
      @vis.name = 'Foo'
      @vis.name.should == 'Foo'
    end

    it 'raises error when name is nil' do
      expect { @vis.name = nil }.to raise_error ::Plotrb::InvalidInputError
    end

    it 'sets width when given' do
      @vis.width = 200
      @vis.width.should == 200
    end

    it 'sets width to 500 by default' do
      @vis.width.should == 500
    end

    it 'raises error when width is not a number' do
      expect { @vis.width = [:foo] }.to raise_error ::Plotrb::InvalidInputError
    end

    it 'sets height when given' do
      @vis.height = 200
      @vis.height.should == 200
    end

    it 'sets height to 500 by default' do
      @vis.height.should == 500
    end

    it 'raises error when height is not a number' do
      expect { @vis.height = [:foo] }.to raise_error ::Plotrb::InvalidInputError
    end

    it 'sets viewport when given as an array' do
      @vis.viewport = [400, 500]
      @vis.viewport.should == [400, 500]
    end

    it 'sets viewport when given as a hash' do
      @vis.viewport = {:width => 400, :height => 500}
      @vis.viewport.should == [400, 500]
    end

    it 'sets viewport to default width and height when not given' do
      vis = ::Plotrb::Visualization.new(:width => 300, :height => 400)
      vis.viewport.should == [300, 400]
    end

    it 'raises error when viewport contains nil' do
      expect { @vis.viewport = [100, :foo] }.
          to raise_error ::Plotrb::InvalidInputError
    end

    it 'sets padding when given as an integer' do
      @vis.padding = 2
      @vis.padding.should == {:top => 2, :left => 2, :right => 2, :bottom => 2}
    end

    it 'sets padding when given as a hash' do
      @vis.padding = {:bottom => 5, :top => 4, :right => 3, :left => 2 }
      @vis.padding.should == {:top => 4, :left => 2, :right => 3, :bottom => 5}
    end

    it 'sets padding to 5 by default' do
      @vis.padding = {:top => 5, :left => 5, :right => 5, :bottom => 5}
    end

    it 'raises error when any padding value is missing' do
      expect { @vis.padding = {:top => 4} }.
          to raise_error ::Plotrb::InvalidInputError
    end

    it 'raises error when any padding value is not a number' do
      expect { @vis.padding = {:top => 4, :left => :foo,
                               :right => 'bar', :bottom => nil} }.
          to raise_error ::Plotrb::InvalidInputError
    end

  end

end
