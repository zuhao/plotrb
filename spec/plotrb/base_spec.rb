require_relative '../spec_helper'

describe 'Base' do

  class FooClass
    include ::Plotrb::Base
  end

  class BarClass
  end

  class BazClass
  end

  describe 'ClassMethods' do

    let(:foo) { Class.new { include ::Plotrb::Base } }

    describe '.attributes' do

      it 'has attributes' do
        foo.respond_to?(:attributes).should be_true
      end

    end

    describe '.add_attributes' do

      before(:each) do
        foo.class_eval { add_attributes :foo_foo }
      end

      it 'keeps track of all attributes defined for class' do
        foo.attributes.should match_array([:foo_foo])
      end

      it 'adds setter method for the attribute' do
        bar = foo.new
        bar.foo_foo = 1
        bar.instance_variable_get(:@foo_foo).should == 1
      end

    end

  end

  describe '#attributes' do

    let(:foo) { FooClass.new }
    before(:each) do
      foo.singleton_class.class_eval { add_attributes :foo_foo }
    end

    it 'tracks both class-defined and instance-defined attributes' do
      foo.add_attributes(:bar_bar)
      foo.attributes.should match_array([:foo_foo, :bar_bar])
    end

  end

  describe '#set_attribuets' do

    let(:foo) { FooClass.new }

    it 'creates attributes and sets values' do
      foo.set_attributes(a: 1, b: 2)
      foo.attributes.should match_array([:a, :b])
      foo.instance_variable_get(:@a).should == 1
      foo.instance_variable_get(:@b).should == 2
    end

  end

  describe '#add_attributes' do

    let(:foo) { FooClass.new }
    let(:bar) { FooClass.new }
    before(:each) do
      FooClass.add_attributes(:foo_class)
    end

    it 'adds attributes to specific instance only' do
      foo.add_attributes(:foo_foo)
      bar.add_attributes(:bar_bar)
      foo.attributes.should match_array([:foo_class, :foo_foo])
      bar.attributes.should match_array([:foo_class, :bar_bar])
    end

  end

  describe '#defined_attributes' do

    let(:foo) { FooClass.new }

    it 'only returns non-nil attributes' do
      foo.set_attributes(a: 1, b: 2, c: nil)
      foo.defined_attributes.should match_array([:a, :b])
    end

  end

  describe '#collect_attributes' do

    let(:foo) { FooClass.new }
    let(:bar) { BarClass.new }
    let(:baz) { BazClass.new }
    before(:each) do
      foo.add_attributes(:attr)
    end

    it 'recursively collects attributes' do
      BarClass.any_instance.stub(:respond_to?).with(:collect_attributes).
          and_return(true)
      BarClass.any_instance.stub(:collect_attributes).and_return('bar_values')
      foo.attr = bar
      foo.collect_attributes.should == { 'attr' => 'bar_values' }
    end

    it 'collects attributes of each of the array element' do
      BarClass.any_instance.stub(:respond_to?).with(:collect_attributes).
          and_return(true)
      BazClass.any_instance.stub(:respond_to?).with(:collect_attributes).
          and_return(true)
      BarClass.any_instance.stub(:collect_attributes).and_return('bar_values')
      BazClass.any_instance.stub(:collect_attributes).and_return('baz_values')
      foo.attr = [bar, baz]
      foo.collect_attributes.should == { 'attr' => %w(bar_values baz_values)}
    end

    it 'collects name reference if an object in given'

  end

  describe '#define_boolean_attribute' do

    let(:foo) { FooClass.new }

    before(:each) do
      foo.define_boolean_attribute(:bar)
    end

    it 'creates setter' do
      foo.respond_to?(:bar).should be_true
    end

    it 'sets attribute to true when called' do
      foo.bar
      foo.instance_variable_get('@bar').should == true
    end

    it 'creates getter' do
      foo.respond_to?(:bar?).should be_true
    end

  end

  describe '#define_single_val_attribute' do

    let(:foo) { FooClass.new }

    context 'when no proc is provided' do

      before(:each) do
        foo.define_single_val_attribute(:bar)
      end

      it 'creates setter and getter' do
        foo.respond_to?(:bar).should be_true
      end

      it 'acts as getter when no argument is provided' do
        foo.should_receive(:instance_variable_get).with('@bar')
        foo.bar
      end

      it 'sets value of the attribute if provided' do
        foo.should_receive(:instance_variable_set).with('@bar', 1)
        foo.bar(1)
      end

      it 'raises error if more than one value is given' do
        expect { foo.bar(1,2,3) }.to raise_error(ArgumentError)
      end

    end

    context 'when a proc is provided' do

      it 'process the value before assigning to the attribute' do
        p = lambda { |x| x + 1}
        foo.define_single_val_attribute(:bar, p)
        foo.bar(1)
        foo.bar.should == 2
      end

      it 'raises error if condition check fails in proc' do
        p = lambda { |x|
          if x > 0
            x + 1
          else
            raise ArgumentError
          end
        }
        foo.define_single_val_attribute(:bar, p)
        foo.bar(1)
        foo.bar.should == 2
        expect { foo.bar(0) }.to raise_error(ArgumentError)
      end

    end

  end

  describe '#define_multi_val_attribute' do

    let(:foo) { FooClass.new }

    context 'when no proc is provided' do

      before(:each) do
        foo.define_multi_val_attribute(:bar)
      end

      it 'creates setter and getter' do
        foo.respond_to?(:bar).should be_true
      end

      it 'acts as getter when no argument is provided' do
        foo.should_receive(:instance_variable_get).with('@bar')
        foo.bar
      end

      it 'sets single value of the attribute if provided' do
        foo.should_receive(:instance_variable_set).with('@bar', [1])
        foo.bar(1)
      end

      it 'sets array of values' do
        foo.should_receive(:instance_variable_set).with('@bar', [1, 2, 3])
        foo.bar([1, 2, 3])
      end

      it 'sets multiple values' do
        foo.should_receive(:instance_variable_set).with('@bar', [1, 2, 3])
        foo.bar(1,2,3)
      end

    end

    context 'when a proc is provided' do

      it 'process the values before assigning to the attribute' do
        p = lambda { |*x| x.each { |v| v + 1 } }
        foo.define_multi_val_attribute(:bar, p)
        foo.bar(1,2,3)
        foo.bar.should == [1, 2, 3]
      end

      it 'is able to check argument size' do
        p = lambda { |x, y, z| [x + 1, y + 1, z + 1] }
        foo.define_multi_val_attribute(:bar, p)
        foo.bar(1,2,3)
        foo.bar.should == [2, 3, 4]
        expect { foo.bar(1,2,3,4) }.to raise_error(ArgumentError)
      end
    end

  end

  describe '#classify' do

    let(:foo) { Class.new { extend ::Plotrb::Base } }

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

  describe 'Hash' do

    describe '#reverse_merge' do

      it 'should respond to reverse_merge' do
        Hash.new.respond_to?(:reverse_merge).should be_true
      end

      it 'reverse merges hash' do
        hash = {a: 1, b: 2}
        default = {a:2, c:3}
        hash.reverse_merge(default).should == {a: 1, b: 2, c: 3}
      end

    end

    describe '#collect_attributes' do

      it 'should respond to collect_attributes' do
        Hash.new.respond_to?(:collect_attributes).should be_true
      end

      it 'recursively collects attributes' do
        hash = {foo: FooClass.new, bar: BarClass.new}
        FooClass.any_instance.stub(:collect_attributes).and_return('foo_value')
        BarClass.any_instance.stub(:collect_attributes).and_return('bar_value')
        hash.collect_attributes.should == {'foo' => 'foo_value',
                                           'bar' => 'bar_value'}
      end

    end

  end

end
