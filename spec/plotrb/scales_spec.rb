require_relative '../spec_helper'

describe 'Scale' do

  subject { ::Plotrb::Scale.new }

  describe '#name' do

    it 'sets name of the scale' do
      subject.name 'foo_scale'
      subject.name.should == 'foo_scale'
    end

    it 'raises error if the name is not unique'

  end

  describe '#type' do

    it 'does not allow changing type once initialized' do
      expect { subject.type(:other_type) }.to raise_error(ArgumentError)
    end

  end

  describe '#domain' do

    context 'when domain is a string reference to a data source' do

      let(:data_ref) { ::Plotrb::Scale::DataRef }

      it 'separates data source and data field' do
        subject.from('some_data.some_field')
        subject.domain.data.should == 'some_data'
        subject.domain.field.should == 'data.some_field'
      end

      it 'defaults field to index if not provided' do
        subject.from('some_data')
        subject.domain.data.should == 'some_data'
        subject.domain.field.should == 'index'
      end

    end

    context 'when domain is actual ordinal/categorical data' do

      it 'sets domain directly' do
        data_set = %w(foo bar baz qux)
        subject.from(data_set)
        subject.domain.should == data_set
      end

    end

    context 'when domain is a quantitative range' do

      it 'sets domain as a two-element array' do
        subject.from([1,100])
        subject.domain.should == [1,100]
      end

    end

  end

  describe '#range' do

    context 'when range is numeric' do

      it 'sets range as a two-element array' do
        subject.to([1,100])
        subject.range.should == [1,100]
      end

    end

    context 'when range is ordinal' do

      it 'sets range directly' do
        range_set = %w(foo bar baz qux)
        subject.to(range_set)
        subject.range.should == range_set
      end

    end

    context 'when range is special literal' do

      it 'sets correct range literal' do
        subject.to_colors
        subject.range.should == :category10
        subject.to_more_colors
        subject.range.should == :category20
        subject.to_shapes
        subject.range.should == :shapes
      end

      it 'does not set invalid range literal' do
        expect { subject.to_foo_bar_range }.to raise_error(NoMethodError)
        subject.range.should be_nil
      end

    end

  end

  describe '#exponent' do

    it 'sets the exponent of scale transformation' do
      subject.in_exponent(10)
      subject.exponent.should == 10
    end

  end

  describe '#nice' do

    context 'when scale is time or utc' do

      subject { ::Plotrb::Scale.time }

      it 'sets valid nice literal' do
        subject.in_seconds
        subject.nice.should == :second
      end

      it 'does not set invalid nice literal' do
        expect { subject.in_millennium }.to raise_error(NoMethodError)
        subject.nice.should be_nil
      end

    end

    context 'when scale is quantitative' do

      subject { ::Plotrb::Scale.linear }

      it 'sets nice to true' do
        subject.nicely
        subject.nice?.should be_true
      end

    end

  end

  describe '#method_missing' do

    it 'calls nice if in_foo is called' do
      subject.type = :time
      subject.should_receive(:nice).with(:second)
      subject.in_seconds
    end

    it 'calls range if to_foo is called' do
      subject.should_receive(:range).with(:colors)
      subject.to_colors
    end

  end

  it 'allows block-style DSL' do
    subject.name('some_scale') do
      from('some_data_file.some_field').to_width
      reverse
      nicely
    end
    subject.name.should == 'some_scale'
    subject.domain.data.should == 'some_data_file'
    subject.domain.field.should == 'data.some_field'
    subject.range.should == :width
    subject.reverse.should be_true
    subject.nice?.should be_true
  end

end
