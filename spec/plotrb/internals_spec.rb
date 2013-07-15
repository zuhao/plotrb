require_relative '../spec_helper'
require_relative '../../lib/plotrb/internals'

describe 'Internals' do

  describe 'setting attributes for each instance' do

    class FooClass
      include ::Plotrb::Internals
      attr_accessor :bar_bar
      def initialize
        self.singleton_class.class_eval do
          attr_accessor :bar, :baz
        end
      end
    end

    class Foo2Class < FooClass
      def initialize
        self.singleton_class.class_eval do
          attr_accessor :bar2
        end
      end
    end

    class BarClass
      include ::Plotrb::Internals
      def initialize
        self.singleton_class.class_eval do
          attr_accessor :qux
        end
      end
    end

    let(:foo) { FooClass.new }
    let(:bar) { BarClass.new }
    let(:foo2) { Foo2Class.new }

    it 'has attributes' do
      foo.respond_to?(:attributes).should be_true
    end

    it 'keeps track of attributes defined via attr_accessor' do
      foo.attributes.should match_array([:bar, :baz, :bar_bar])
    end

    it 'limits attributes to single instance' do
      foo2.attributes.should_not include(:bar, :baz)
      foo2.attributes.should include(:bar2)
    end

    it 'sets attributes' do
      foo.set_attributes({:a => 1, :b => 2})
      foo.a.should == 1
      foo.b.should == 2
    end

    it 'lists all defined attributes' do
      foo.bar_bar = 1
      foo.baz = 2
      foo.defined_attributes.should match_array([:bar_bar, :baz])
    end

  end

end