require_relative '../spec_helper'

describe 'Mark' do

  subject { ::Plotrb::Mark.rect }

  describe '#initialize' do

    context 'when type is group' do

      subject { ::Plotrb::Mark.group }

      it 'has additional scales, axes, and marks attribute' do
        subject.attributes.should include(:scales, :axes, :marks)
      end

    end

  end

  describe 'properties' do

    it 'allows multiple properties' do
      ::Plotrb::Kernel.stub(:find_data).with('some_data').and_return(true)
      subject.from('some_data')
      subject.enter
      subject.exit
      subject.properties.keys.should match_array([:enter, :exit])
    end

  end

  describe '#from' do

    it 'recognizes Data and Transform objects' do
      foo = ::Plotrb::Transform.facet
      bar = ::Plotrb::Transform.filter
      ::Plotrb::Kernel.stub(:find_data).with('some_data').and_return(true)
      subject.from('some_data', foo, bar)
      subject.send(:process_from)
      subject.from.should == {:data => 'some_data', :transform => [foo, bar]}
    end

  end

end
