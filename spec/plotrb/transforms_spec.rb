require_relative '../spec_helper'

describe 'Transform' do

  describe '#initialize' do

    subject { Plotrb::Transform }

    it 'calls respective type method to initialize attributes' do
      subject.any_instance.should_receive(:send).with(:foo)
      subject.new(:foo)
    end

    it 'raises error if type is not recognized' do
      expect { subject.new(:foo) }.to raise_error(NoMethodError)
    end

  end

  describe '#array' do

    subject { Plotrb::Transform.new(:array) }

    it 'responds to #take' do
      subject.take('foo', 'bar')
      subject.send(:process_array_fields)
      subject.fields.should match_array(['data.foo', 'data.bar'])
    end

  end

  describe '#copy' do

    subject { Plotrb::Transform.new(:copy) }

    it 'responds to #take' do
      subject.take('foo_field', 'bar_field').from('some_data').as('foo', 'bar')
      subject.fields.should match_array(['foo_field', 'bar_field'])
    end

    it 'raises error if as and fields are of different size' do
      subject.take('foo', 'bar').from('data').as('baz')
      expect { subject.send(:process_copy_as) }.to raise_error(ArgumentError)
    end

  end

  describe '#cross' do

    subject { Plotrb::Transform.new(:cross) }

    it 'raises error if the secondary data does not exist' do
      subject.with('foo')
      ::Plotrb::Kernel.stub(:find_data).and_return(nil)
      expect { subject.send(:process_cross_with) }.to raise_error(ArgumentError)
    end

  end

  describe '#facet' do

    subject { Plotrb::Transform.new(:facet) }

    it 'responds to #group_by' do
      subject.group_by('foo', 'bar')
      subject.send(:process_facet_keys)
      subject.keys.should match_array(['data.foo', 'data.bar'])
    end

  end

  describe '#filter' do

    subject { Plotrb::Transform.new(:filter) }

    it 'adds variable d if not present in the test expression' do
      subject.test('x>10')
      expect { subject.send(:process_filter_test) }.to raise_error(ArgumentError)
    end

  end

  describe '#flatten' do

    subject { Plotrb::Transform.new(:flatten) }

  end

  describe '#fold' do

    subject { Plotrb::Transform.new(:fold) }

    it 'responds to #into' do
      subject.into('foo', 'bar')
      subject.send(:process_fold_fields)
      subject.fields.should match_array(['data.foo', 'data.bar'])
    end

  end

  describe '#formula' do

    subject { Plotrb::Transform.new(:formula) }

    it 'responds to #apply and #into' do
      subject.apply('some_expression').into('some_field')
      subject.field.should == 'some_field'
      subject.expr.should == 'some_expression'
    end

  end

  describe '#slice' do

    subject { Plotrb::Transform.new(:slice) }

    it 'slices by a single value'

    it 'slices by a range'

    it 'slices by special positions'

    it 'raises error otherwise'

  end

  describe '#sort' do

    subject { Plotrb::Transform.new(:sort) }

    it 'adds - in front for reverse sort'

  end

  describe '#stats' do

    subject { Plotrb::Transform.new(:stats) }

    it 'responds to #from, #include_median, and #store_stats' do
      subject.from('foo').include_median.store_stats
      subject.value.should == 'foo'
      subject.median.should be_true
      subject.assign.should be_true
    end

  end

  describe '#truncate' do

    subject { Plotrb::Transform.new(:truncate) }

    it 'responds to #from, #to, and #max_length' do
      subject.from('foo').to('bar').max_length(5)
      subject.send(:process_truncate_value)
      subject.value.should == 'data.foo'
      subject.output.should == 'bar'
      subject.limit.should == 5
    end

    it 'responds to #in_position' do
      subject.in_front
      subject.position.should == :front
    end

  end

  describe '#unique' do

    subject { Plotrb::Transform.new(:unique) }

    it 'responds to #from and #to' do
      subject.from('foo').to('bar')
      subject.send(:process_unique_field)
      subject.field.should == 'data.foo'
      subject.as.should == 'bar'
    end

  end

  describe '#window' do

    subject { Plotrb::Transform.new(:window) }

  end

  describe '#zip' do

    subject { Plotrb::Transform.new(:zip) }

    it 'responds to #match and #against' do
      subject.with('foo').as('bar').match('foo_field').against('bar_field')
      subject.send(:process_zip_key)
      subject.send(:process_zip_with_key)
      subject.key.should == 'data.foo_field'
      subject.with_key.should == 'data.bar_field'
    end

  end

  describe '#force' do

    subject { Plotrb::Transform.new(:force) }

  end

  describe '#geo' do

    subject { Plotrb::Transform.new(:geo) }

  end

  describe '#geopath' do

    subject { Plotrb::Transform.new(:geopath) }

  end

  describe '#link' do

    subject { Plotrb::Transform.new(:link) }

  end

  describe '#pie' do

    subject { Plotrb::Transform.new(:pie) }

  end

  describe '#stack' do

    subject { Plotrb::Transform.new(:stack) }

  end

  describe '#treemap' do

    subject { Plotrb::Transform.new(:treemap) }

  end

  describe '#wordcloud' do

    subject { Plotrb::Transform.new(:wordcloud) }

  end

end
