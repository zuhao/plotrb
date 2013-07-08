module Plotrb

  # Scales are functions that transform a domain of data values to a range of
  #   visual values.
  # See {https://github.com/trifacta/vega/wiki/Scales}
  class Scale

    def initialize

    end

    # Common Scale Properties

    attr_accessor :name, :type, :domain, :domain_min, :domain_max,
                  :range, :range_min, :range_max, :reverse, :round

    # @param name [String] unique name of the scale
    def name=(name)
      @name = name.to_s
      raise ::Plotrb::InvalidInputError if @name.empty?
    end

    # @param type [Symbol, String] the type of scale
    def type=(type)
      if valid_type?(type)
        @type = type.to_sym
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # @param domain [Array(Numeric, Numeric), Array, String] the domain of the
    #   scale, representing the set of data values
    def domain=(domain)
      if valid_domain?(domain)
        @domain = domain
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # @param domain_min [Numeric, String] the minimum value in the scale domain
    def domain_min=(domain_min)
      @domain_min = domain_min
    end

    # @param domain_max [Numeric, String] the maximum value in the scale domain
    def domain_max=(domain_max)
      @domain_max = domain_max
    end

    # @param range [Array(Numeric, Numeric), Array, String] the range of the
    #   scale, representing the set of visual values
    def range=(range)
      if valid_range?(range)
        @range = range
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # @param range_min [Numeric, String] the minimum value in the scale range
    def range_min=(range_min)
      @range_min = range_min
    end

    # @param range_max [Numeric, String] the maximum value in the scale range
    def range_max=(range_max)
      @range_max = range_max
    end

    # @param reverse [Boolean] whether flips the scale range
    def reverse=(reverse)
      @reverse = reverse
    end

    # @param round [Boolean] whether rounds numeric output values to integers
    def round=(round)
      @round = round
    end

    # Ordinal Scale Properties

    attr_accessor :points

    # @param points [Boolean] whether distributes the ordinal values over a
    #   quantitative range at uniformly spaced points or bands
    def points=(points)
      @points = points
    end

    # Time Scale Properties

    attr_accessor :clamp, :nice

    # @param clamp [Boolean] whether clamps values that exceed the data domain
    #   to either to minimum or maximum range value
    def clamp=(clamp)
      @clamp = clamp
    end

    # @param nice [Symbol, Boolean, nil] scale domain ina more human-friendly value range
    def nice=(nice)
      if valid_nice?(nice)
        @nice = nice
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # Quantitative Scale Properties

    attr_accessor :exponent, :zero

    # @param exponent [Numeric] the exponent of the scale transformation
    def exponent=(exponent)
      @exponent = exponent
    end

    # @param zero [Boolean] whether zero baseline value is included
    def zero=(zero)
      @zero = zero
    end

    # Scale Domains

    attr_accessor :data, :field

    # @param data [String] the name of the data set containing domain values
    def data=(data)
      @data =data
    end

    # @param field [String, Array<String>] reference to the desired data fields
    def field=(field)
      @field = field
    end

  private

    def valid_type?(type)
      [:linear, :ordinal, :time, :utc, :log, :pow, :sqrt, :quantile,
       :quantize, :threshold].include?(type.to_sym)
    end

    def valid_domain?(domain)

    end

    def valid_range?(range)

    end

    def valid_nice?(nice)
      if [:time, :utc].include?(@type)
        [:second, :minute, :hour, :day, :week, :month, :year].include?(nice)
      else
        [true, false].include?(nice)
      end
    end

  end

end