require 'yajl'
require 'uri'

module Plotrb

  # The basic tabular data model used by Vega.
  # See {https://github.com/trifacta/vega/wiki/Data}
  class Data

    attr_accessor :name, :format, :values, :source, :url, :transform

    def initialize(args={})
      @name       = args[:name]
      @format     = args[:format]
      @values     = args[:values]
      @source     = args[:source]
      @url        = args[:url]
      @transform  = args[:transform]
    end

    # @param name [#to_s] unique name of the data set
    def name=(name)
      @name = name.to_s
      if @name.nil? || @name.empty?
        raise ::Plotrb::InvalidInputError
      end
    end

    # @param format [Hash] the format for the data file
    def format=(format)
      if format.is_a?(Hash) && format[:type] &&
          [:json, :csv, :tsv].include?(format[:type]) &&
          self.send("valid_#{format[:type].to_s}_format?", format)
        @format = format
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # @param values [Hash] the actual data set
    def values=(values)
      @values = Yajl::Parser.parse(values)
    rescue Yajl::ParseError
      raise ::Plotrb::InvalidInputError
    end

    # @param source [String] the name of another data set to us as source
    def source=(source)
      if valid_source?(source)
        @source = source
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # @param url [String] the url from which to load the data set
    def url=(url)
      u = URI.parse(url)
      if u
        @url = u.to_s
      end
    rescue URI::InvalidURIError
      raise ::Plotrb::InvalidInputError
    end

    # @param transform [Array<Transform>] an array of transform definitions
    def transform=(transform)
      if valid_transform?(transform)
        @transform = transform
      else
        raise ::Plotrb::InvalidInputError
      end
    end

  private

    # @param source [String] the name of another data set to us as source
    def valid_source?(source)
      return true unless source
      #TODO: check if source data set exists.
    end

    # @param format [Hash] the format object
    def valid_json_format?(format)
      valid = true
      if format[:parse]
        format[:parse].each do |_, v|
          valid &= [:number, :boolean, :date].include?(v)
        end
      end
      if format[:property]
        valid &= format[:property].is_a?(String)
      end
      valid
    rescue
      false
    end

    # (see #valid_json_format?)
    def valid_csv_format?(format)
      valid = true
      if format[:parse]
        format[:parse].each do |_, v|
          valid &= [:number, :boolean, :date].include?(v)
        end
      end
      valid
    rescue
      false
    end

    # (see #valid_json_format?)
    def valid_tsv_format?(format)
      valid = true
      if format[:parse]
        format[:parse].each do |_, v|
          valid &= [:number, :boolean, :date].include?(v)
        end
      end
      valid
    rescue
      false
    end

    # @param transform [nil, Array<Transform>] an array of transform definitions
    def valid_transform?(transform)
      transform.is_a?(Array) &&
          transform.all? { |t| t.is_a?(::Plotrb::Transform) }
    end

  end

end