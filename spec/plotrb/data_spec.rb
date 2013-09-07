require_relative '../spec_helper'

describe 'Data' do

  subject { ::Plotrb::Data.new }

  describe '#name' do

    it 'sets name if valid' do
      subject.name = 'foo'
      subject.name.should == 'foo'
    end

    it 'raises error if name is nil'

    it 'raises error if name is not unique'

  end

  describe '#format' do

    it 'sets format as a new Format instance' do
      ::Plotrb::Data::Format.should_receive(:new).with(:foo)
      subject.format(:foo)
    end

  end

  describe '#values' do

    it 'sets values if valid JSON is given' do
      subject.values('{"foo":1, "bar":{"baz":2}}')
      subject.values.should == '{"foo":1, "bar":{"baz":2}}'
    end

    it 'sets values if array is given' do
      subject.values([1,2,3,4])
      subject.values.should match_array([1,2,3,4])
    end

    it 'sets values if hash is given' do
      subject.values(foo: 1, bar: 2)
      subject.values.should == {foo: 1, bar: 2}
    end

    it 'raises error if values are invalid JSON' do
      expect { subject.values("{foo:1, 'bar':}") }.to raise_error ArgumentError
    end

  end

  describe '#source' do

    it 'sets source if valid' do
      subject.source('foo')
      subject.source.should == 'foo'
    end

    it 'raises error if source does not exist'

    it 'validates existing source'

  end

  describe '#url' do

    it 'sets valid absolute url' do
      subject.url('http://foo.com/bar')
      subject.url.should == 'http://foo.com/bar'
    end

    it 'sets valid relative url' do
      subject.url('data/bar.json')
      subject.url.should == 'data/bar.json'
    end

    it 'raises error when url is invalid' do
      expect { subject.url('http://foo/#-|r|$@') }.to raise_error ArgumentError
    end

  end

  describe '#file' do

    it 'sets url if file exists'

    it 'raises error is file does not exist'

  end

  describe '#transform' do

    class Bar; end

    let(:foo) { ::Plotrb::Transform.new(:array) }
    let(:bar) { Bar.new }

    it 'sets transform if a transform object is given' do
      subject.transform(foo)
      subject.transform.should == [foo]
    end

    it 'sets transform if multiple transforms are given' do
      subject.transform(foo, foo)
      subject.transform.should == [foo, foo]
    end

    it 'raises error if array contains non-transforms' do
      expect { subject.transform(foo, bar) }.to raise_error ArgumentError
    end

  end

  describe '#method_missing' do

    it 'sets format via as_foo' do
      subject.should_receive(:format).with(:csv)
      subject.as_csv
    end

  end

  describe 'Format' do

    it 'raises error if format type is not recognized' do
      expect { ::Plotrb::Data::Format.new(:foo) }.to raise_error ArgumentError
    end

    context 'json' do

      subject { ::Plotrb::Data::Format.new(:json) }

      it 'has parse and property attributes' do
        subject.attributes.should match_array([:format, :parse, :property])
      end

      describe '#parse' do

        it 'sets parse if valid hash is given' do
          subject.parse('foo' => :number, 'bar' => :date)
          subject.parse.should == {'foo' => :number, 'bar' => :date }
        end

        it 'raises error if parse object has unknown data type' do
          expect { subject.parse('foo' => :bar) }.to raise_error ArgumentError
        end

      end

      describe '#as_date' do

        it 'parses the field as date' do
          subject.as_date('foo')
          subject.parse['foo'].should == :date
        end

        it 'allows setting multiple fields' do
          subject.as_date('foo', 'bar')
          subject.parse.should == {'foo' => :date, 'bar' => :date}
        end

      end

      describe '#as_boolean' do

        it 'parses the field as boolean' do
          subject.as_boolean('foo')
          subject.parse['foo'].should == :boolean
        end

      end

      describe '#as_number' do

        it 'parses the field as number' do
          subject.as_number('foo')
          subject.parse['foo'].should == :number
        end

      end

      describe '#property' do

        it 'sets the property' do
          subject.property('values.features')
          subject.property.should == 'values.features'
        end

      end

    end

    context 'csv' do

      subject { ::Plotrb::Data::Format.new(:csv) }

      it 'has parse attribute' do
        subject.attributes.should match_array([:format, :parse])
      end

    end

    context 'tsv' do

      subject { ::Plotrb::Data::Format.new(:tsv) }

      it 'has parse attribute' do
        subject.attributes.should match_array([:format, :parse])
      end

    end

    context 'topojson' do

      subject { ::Plotrb::Data::Format.new(:topojson) }

      it 'has feature and mesh attribute' do
        subject.attributes.should match_array([:format, :feature, :mesh])
      end

    end

    context 'treejson' do

      subject { ::Plotrb::Data::Format.new(:treejson) }

      it 'has parse and children attribute' do
        subject.attributes.should match_array([:format, :parse, :children])
      end

    end

  end

end
