require_relative '../spec_helper'
require_relative '../../lib/plotrb/transforms'

describe 'Transform' do

  describe 'setting properties for each type' do

    class FooClass < ::Plotrb::Transform
      def initialize
        self.singleton_class.class_eval do
          attr_accessor :bar, :baz
        end
      end
    end

    class BarClass < ::Plotrb::Transform
      def initialize
        self.singleton_class.class_eval do
          attr_accessor :qux
        end
      end
    end

    let(:transform) { ::Plotrb::Transform }
    let(:foo) { FooClass.new }
    let(:bar) { BarClass.new }

    it 'raises error if type is unrecognized' do
      expect { transform.new(:foo) }.
          to raise_error ::Plotrb::InvalidInputError
    end

    it 'has properties' do
      foo.respond_to?(:properties).should be_true
    end

    it 'keeps track of properties as attr_accessors' do
      foo.properties.should == [:bar, :baz]
    end

    it 'limits properties to single instance' do
      foo.properties.should_not include(:qux)
      bar.properties.should_not include(:bar, :baz)
    end

    it 'sets properties' do
      foo.set_properties({:a => 1, :b => 2})
      foo.a.should == 1
      foo.b.should == 2
    end

    it 'calls corresponding method for each type' do
      type, args = :foo, {:bar => 'baz'}
      transform.any_instance.stub(:valid_type?).and_return(true)
      transform.any_instance.should_receive(type).with(args)
      transform.new(type, args)
    end

  end

end