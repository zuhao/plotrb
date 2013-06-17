require_relative '../spec_helper'
require_relative '../../lib/plotrb/data'
require_relative '../../lib/plotrb/transforms'

describe 'Data' do

  before(:each) do
    @data = ::Plotrb::Data.new
  end

  context 'when setting name' do

    it 'sets name if valid' do
      @data.name = 'foo'
      @data.name.should == 'foo'
    end

    it 'raises error if name is nil' do
      expect { @data.name = nil }.to raise_error ::Plotrb::InvalidInputError
    end

  end

  context 'when setting format' do

    it 'raises error when format is not a hash' do
      expect { @data.format = :foo }.to raise_error ::Plotrb::InvalidInputError
    end

    it 'raises error when format does not has type' do
      expect { @data.format = {:foo => :bar} }.
          to raise_error ::Plotrb::InvalidInputError
    end

    it 'raises error when format type is not json, csv, or tsv' do
      expect { @data.format = {:type => :foo} }.
          to raise_error ::Plotrb::InvalidInputError
    end

    context 'json' do

      let(:valid_json) { {
          :type => :json,
          :parse => {'modified_on' => :date},
          :property => 'values.features'
      } }
      let(:invalid_json) { {:foo => :bar} }

      it 'validates JSON format' do
        @data.should_receive(:valid_json_format?).with(valid_json).
            and_return(true)
        @data.format = valid_json
      end

      it 'sets JSON format if valid' do
        @data.format = valid_json
        @data.format.should == valid_json
      end

      it 'raises error if invalid JSON format' do
        @data.stub(:valid_json_format?).and_return(false)
        expect { @data.format = invalid_json }.
            to raise_error ::Plotrb::InvalidInputError
      end

      it 'invalidates if parse object has unknown data type' do
        @data.send(:valid_json_format?, {:parse => {'foo' => :bar }}).
            should be_false
      end

      it 'invalidates if parse object is not a hash' do
        @data.send(:valid_json_format?, {:parse => :foo}).should be_false
      end

      it 'invalidates if property is not a string' do
        @data.send(:valid_json_format?, {:property => [:foo]}).should be_false
      end

    end

    context 'csv' do

      let(:valid_csv) { {
          :type => :csv,
          :parse => {'modified_on' => :date},
          :property => 'values.features'
      } }
      let(:invalid_csv) { {:foo => :bar}}

      it 'validates csv format' do
        @data.should_receive(:valid_csv_format?).with(valid_csv).
            and_return(true)
        @data.format = valid_csv
      end

      it 'sets csv format if valid' do
        @data.format = valid_csv
        @data.format.should == valid_csv
      end

      it 'raises error if invalid csv format' do
        @data.stub(:valid_csv_format?).and_return(false)
        expect { @data.format = invalid_csv }.
            to raise_error ::Plotrb::InvalidInputError
      end

      it 'invalidates if parse object has unknown data type' do
        @data.send(:valid_csv_format?, {:parse => {'foo' => :bar }}).
            should be_false
      end

      it 'invalidates if parse object is not a hash' do
        @data.send(:valid_csv_format?, {:parse => :foo}).should be_false
      end

    end

    context 'tsv' do

      let(:valid_tsv) { {
          :type => :tsv,
          :parse => {'modified_on' => :date},
          :property => 'values.features'
      } }
      let(:invalid_tsv) { {:foo => :bar}}

      it 'validates tsv format' do
        @data.should_receive(:valid_tsv_format?).with(valid_tsv).
            and_return(true)
        @data.format = valid_tsv
      end

      it 'sets tsv format if valid' do
        @data.format = valid_tsv
        @data.format.should == valid_tsv
      end

      it 'raises error if invalid tsv format' do
        @data.stub(:valid_tsv_format?).and_return(false)
        expect { @data.format = invalid_tsv }.
            to raise_error ::Plotrb::InvalidInputError
      end

      it 'invalidates if parse object has unknown data type' do
        @data.send(:valid_tsv_format?, {:parse => {'foo' => :bar }}).
            should be_false
      end

      it 'invalidates if parse object is not a hash' do
        @data.send(:valid_tsv_format?, {:parse => :foo}).should be_false
      end

    end

  end

  context 'when setting values' do

    it 'sets values if valid JSON' do
      @data.values = '{"foo":1, "bar":{"gee":2}}'
      @data.values.should == {'foo'=>1, 'bar'=>{'gee'=>2}}
    end

    it 'raises error if values are invalid JSON' do
      expect { @data.values = "{foo:1, 'bar':}" }.
          to raise_error ::Plotrb::InvalidInputError
    end

  end

  context 'when setting source' do

    it 'sets source if valid' do
      @data.stub(:valid_source?).and_return(true)
      @data.source = 'foo'
      @data.source.should == 'foo'
    end

    it 'raises error if source does not exist'

    it 'validates existing source'

    it 'validates nil source' do
      @data.should_receive(:valid_source?).with(nil).and_return(true)
      @data.source = nil
    end

  end

  context 'when setting url' do

    it 'sets valid absolute url' do
      @data.url = 'http://foo.com/bar'
      @data.url.should == 'http://foo.com/bar'
    end

    it 'sets valid relative url' do
      @data.url = 'data/bar.json'
      @data.url.should == 'data/bar.json'
    end

    it 'raises error when url is invalid' do
      expect { @data.url = 'http://foo/#@-$|bar|$-@#' }.
          to raise_error ::Plotrb::InvalidInputError
    end

  end

  context 'when setting transform' do

    class Gee; end

    let(:foo) { ::Plotrb::Transform.new }
    let(:bar) { [:foo, Gee.new]}
    let(:valid_transform) { [:foo, :foo] }

    it 'invalidates if transforms are not in an array' do
      @data.send(:valid_transform?, foo).should be_false
    end

    it 'invalidates if array contains non-transforms' do
      @data.send(:valid_transform?, bar).should be_false
    end

    it 'sets transforms if valid' do
      @data.stub(:valid_transform?).and_return(true)
      @data.transform = valid_transform
      @data.transform.should == valid_transform
    end

    it 'raises error if transforms are invalid' do
      @data.stub(:valid_transform?).and_return(false)
      expect { @data.transform = bar }.
          to raise_error ::Plotrb::InvalidInputError
    end

  end

end