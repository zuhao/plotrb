module Plotrb

  # The basic tabular data model used by Vega.
  # See {https://github.com/trifacta/vega/wiki/Data}
  class Data

    include ::Plotrb::Base

    # @!attributes name
    #   @return [String] the name of the data set
    # @!attributes format
    #   @return [Hash] the format of the data file
    # @!attributes values
    #   @return [Hash] the actual data set
    # @!attributes source
    #   @return [String] the name of another data set to use as source
    # @!attributes url
    #   @return [String] the url from which to load the data set
    # @!attributes transform
    #   @return [Array<Transform>] an array of transform definitions
    attr_accessor :name, :format, :values, :source, :url, :transform

    def initialize(args={})
      args.each do |k, v|
        self.instance_variable_set("@#{k}", v) if self.attributes.include?(k)
      end
    end

      end

      end
    end

      end
    end

    class FormatValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors.add(attribute, 'invalid format') unless
            valid_format_key?(value) && valid_format_value?(value)
      end

      def valid_format_key?(format)
        format.is_a?(Hash) && [:json, :csv, :tsv].include?(format[:type])
      end

      def valid_format_value?(format)
        valid = true
        if format[:parse]
          format[:parse].each do |_, v|
            valid = false unless [:number, :boolean, :date].include?(v)
          end
        end
        valid
      end
    end


  end

end