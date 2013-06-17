require 'yajl'
require 'uri'

module Plotrb

  class Data

    def initialize(args={})
      @name       = args[:name]
      @format     = args[:format]
      @values     = args[:values]
      @source     = args[:source]
      @url        = args[:url]
      @transform  = args[:transform]
    end

    def name
      @name
    end

    def name=(name)
      @name = name.to_s
      if @name.nil? || @name.empty?
        raise ::Plotrb::InvalidInputError
      end
    end

    def format
      @format
    end

    def format=(format)
      if format.is_a?(Hash) && format[:type] &&
          [:json, :csv, :tsv].include?(format[:type]) &&
          self.send("valid_#{format[:type].to_s}_format?", format)
        @format = format
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    def values
      @values
    end

    def values=(values)
      @values = Yajl::Parser.parse(values)
    rescue Yajl::ParseError
      raise ::Plotrb::InvalidInputError
    end

    def source
      @source
    end

    def source=(source)
      if valid_source?(source)
        @source = source
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    def url
      @url
    end

    def url=(url)
      u = URI.parse(url)
      if u
        @url = u.to_s
      end
    rescue URI::InvalidURIError
      raise ::Plotrb::InvalidInputError
    end

    def transform
      @transform
    end

    def transform=(transform)
      if valid_transform?(transform)
        @transform = transform
      else
        raise ::Plotrb::InvalidInputError
      end
    end

  private

    def valid_source?(source)
      return true unless source
      #TODO: check if source data set exists.
    end

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

    def valid_transform?(transform)
      valid = true if transform.nil?
      valid ||= transform.is_a?(Array) &&
          transform.reject{ |t| t.is_a? ::Plotrb::Transform }.empty?
      valid
    end

  end

end