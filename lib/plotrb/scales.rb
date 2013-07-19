module Plotrb

  # Scales are functions that transform a domain of data values to a range of
  #   visual values.
  # See {https://github.com/trifacta/vega/wiki/Scales}
  class Scale

    include ::Plotrb::Internals
    include ActiveModel::Validations

    # @!attributes name
    #   @return [String] the name of the scale
    # @!attributes type
    #   @return [Symbol] the type of the scale
    # @!attributes domain
    #   @return [Array(Numeric, Numeric), Array, String] the domain of the
    #     scale, representing the set of data values
    # @!attributes domain_min
    #   @return [Numeric, String] the minimum value in the scale domain
    # @!attributes domain_max
    #   @return [Numeric, String] the maximum value in the scale domain
    # @!attributes range
    #   @return [Array(Numeric, Numeric), Array, String] the range of the
    #     scale, representing the set of visual values
    # @!attributes range_min
    #   @return [Numeric, String] the minimum value in the scale range
    # @!attributes range_max
    #   @return [Numeric, String] the maximum value in the scale range
    # @!attributes reverse
    #   @return [Boolean] whether flips the scale range
    # @!attributes round
    #   @return [Boolean] whether rounds numeric output values to integers
    # @!attributes points
    #   @return [Boolean] whether distributes the ordinal values over a
    #     quantitative range at uniformly spaced points or bands
    # @!attributes clamp
    #   @return [Boolean] whether clamps values that exceed the data domain
    #     to either to minimum or maximum range value
    # @!attributes nice
    #   @return [Symbol, Boolean, nil] scale domain in a more human-friendly
    #     value range
    # @!attributes exponent
    #   @return [Numeric] the exponent of the scale transformation
    # @!attributes zero
    #   @return [Boolean] whether zero baseline value is included
    # @!attributes data
    #   @return [String] the name of the data set containing domain values
    # @!attributes field
    #   @return [String, Array<String>] reference to the desired data fields
    attr_accessor :name, :type, :domain, :domain_min, :domain_max, :range,
                  :range_min, :range_max, :reverse, :round, :points, :clamp,
                  :nice, :exponent, :zero

    RANGE_LITERALS = %i(width height shapes colors more_colors)
    TIME_SCALE_NICE = %i(second minute hour day week month year)

    class DomainValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors.add(attribute, 'invalid domain')
      end
    end

    validates :name, presence: true, length: { minimum: 1 }
    validates :type, allow_nil: true,
              inclusion: { in: %i(linear ordinal time utc log pow sqrt quantile
                                  quantize threshold) }

    def initialize(args={})
      args.each do |k, v|
        self.instance_variable_set("@#{k}", v) if self.attributes.include?(k)
      end
      self
    end

    def from(data, min=nil, max=nil)
      @domain =
          case data
            when String
              source, field = data.split('.', 2)
              if field.nil? || field == 'index'
                ::Plotrb::DataRef.new(data: source, field: 'index')
              else
                ::Plotrb::DataRef.new(data: source, field: "data.#{field}")
              end
            else
                data
            end
      @domain_min = min
      @domain_max = max
      self
    end

    def to(data, min=nil, max=nil)
      @range = data
      @range_min = min
      @range_max = max
      self
    end

    def to_range_literal(literal)
      @range =
          case literal
            when :colors
              :category10
            when :more_colors
              :category20
            when :width, :height, :shapes
              literal
            else
              nil
          end
      self
    end

    def reverse
      @reverse = true
      self
    end

    def round
      @round = true
      self
    end

    def as_points
      @points = true
      self
    end

    def as_bands
      @points = false
      self
    end

    def in_exponent(exp)
      @exponent = exp
      self
    end

    def nicely(val=nil)
      if %i(time utc).include?(@type)
        @nice = val
      else
        @nice = true
      end
      self
    end

    def include_zero
      @zero = true
      self
    end

    def clamp
      @clamp = true
      self
    end

    def method_missing(method, *args, &block)
      case method.to_s
        when /(\w+)\?$/ # return value of the attribute, eg. type?
          if attributes.include?($1.to_sym)
            self.instance_variable_get("@#{$1.to_sym}")
          else
            super
          end
        when /in_(\w+)s$/ # set @nice for time and utc type, eg. in_seconds
          if TIME_SCALE_NICE.include?($1.to_sym)
            self.nicely($1.to_sym)
          else
            super
          end
        when /to_(\w+)$/ # set range literals, eg. to_more_colors
          if RANGE_LITERALS.include?($1.to_sym)
            self.to_range_literal($1.to_sym)
          else
            super
          end
        else
          super
      end
    end

  end

  # A data reference specifies the field for a given scale property
  class DataRef

    include ::Plotrb::Internals

    # @!attributes data
    #   @return [String] the name of a data set
    # @!attributes field
    #   @return [String] A field from which to pull a data values
    attr_accessor :data, :field

    def initialize(args={})
      args.each do |k, v|
        self.instance_variable_set("@#{k}", v) if self.attributes.include?(k)
      end
    end

  end

end