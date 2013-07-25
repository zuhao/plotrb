require_relative '../spec_helper'

describe 'Transform', :broken => true do

  let(:transform) { ::Plotrb::Transform }

  describe 'setting copy transform' do

    it 'raises error if "as" and "fields" do not have same size' do
      type = :copy
      args = {:from => :foo, :fields => %w(foo, bar), :as => %W(qux)}
      expect { transform.new(type, args) }.
          to raise_error ::Plotrb::InvalidInputError
    end

  end

end