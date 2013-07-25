require_relative '../spec_helper'

describe 'Internals', :broken => true do

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

    it 'keeps track of all attributes defined via attr_accessor' do
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

  describe 'classifying strings' do

    class Foo
      include ::Plotrb::Internals
    end

    let(:foo) { Foo.new }

    it 'classifies string' do
      foo.classify('visualization').should == 'Visualization'
    end

    it 'changes snake_case to CamelCase' do
      foo.classify('foo_bar').should == 'FooBar'
    end

    it 'changes snake_case to camelCaseInJson' do
      foo.classify('foo_bar_baz', :json).should == 'fooBarBaz'
    end

  end

  describe 'collecting attributes into hash' do

    class Foo
      include ::Plotrb::Internals
      attr_accessor :attr
    end

    class Bar; end

    class Baz; end

    let(:foo) { Foo.new }
    let(:bar) { Bar.new }
    let(:baz) { Baz.new }

    it 'recursively collects attributes' do
      Bar.any_instance.stub(:respond_to?).with(:collect_attributes).
          and_return(true)
      Bar.any_instance.stub(:collect_attributes).and_return('bar_values')
      foo.attr = bar
      foo.collect_attributes.should == { 'attr' => 'bar_values' }
    end

    it 'collects attributes of each of the array element' do
      Bar.any_instance.stub(:respond_to?).with(:collect_attributes).
          and_return(true)
      Baz.any_instance.stub(:respond_to?).with(:collect_attributes).
          and_return(true)
      Bar.any_instance.stub(:collect_attributes).and_return('bar_values')
      Baz.any_instance.stub(:collect_attributes).and_return('baz_values')
      foo.attr = [bar, baz]
      foo.collect_attributes.should == { 'attr' => %w(bar_values baz_values)}
    end

  end

end