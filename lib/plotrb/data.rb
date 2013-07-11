module Plotrb

  # The basic tabular data model used by Vega.
  # See {https://github.com/trifacta/vega/wiki/Data}
  class Data

    include ::Plotrb::Internals
    include ::Plotrb::Validators
    include ActiveModel::Validations

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
      @name       = args[:name]
      @format     = args[:format]
      @values     = args[:values]
      @source     = args[:source]
      @url        = args[:url]
      @transform  = args[:transform]
    end

    class UrlValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors.add(attribute, 'invalid url') unless valid_url?(value)
      end

      def valid_url?(url)
        URI.parse(url)
      rescue URI::InvalidURIError
        false
      end
    end

    class TransformValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors.add(attribute, 'invalid viewport') unless
            ::Plotrb::Validators::array_of_transform?(value)
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

    validates :name, presence: true, length: { minimum: 1 }
    validates :source, allow_nil: true, length: { minimum: 1 }
    validates :url, allow_nil: true, url: true
    validates :transform, allow_nil: true, transform: true
    validates :format, allow_nil: true, format: true

  end

end