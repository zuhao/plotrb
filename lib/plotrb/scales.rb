module Plotrb

  # Scales are functions that transform a domain of data values to a range of
  #   visual values.
  # See {https://github.com/trifacta/vega/wiki/Scales}
  class Scale

    include ::Plotrb::Base

    TYPES = %i(linear log pow sqrt quantile quantize threshold ordinal time utc)

    TYPES.each do |t|
      define_singleton_method(t) do |&block|
        ::Plotrb::Scale.new(t, &block)
      end
    end

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

    SCALE_PROPERTIES = [:name, :type, :domain, :domain_min, :domain_max, :range,
                        :range_min, :range_max, :reverse, :round]

    add_attributes *SCALE_PROPERTIES

    RANGE_LITERALS = %i(width height shapes colors more_colors)
    TIME_SCALE_NICE = %i(second minute hour day week month year)

    def initialize(type=:linear, &block)
      @type = type
      case @type
        when :ordinal
          self.send(:ordinal_scale)
        when :time, :utc
          self.send(:time_scale)
        else
          self.send(:quantitative_scale)
      end
      define_single_val_attributes :name
      define_boolean_attributes :reverse, :round
      self.instance_eval(&block) if block_given?
      self
    end

    def type
      @type
    end

    def domain(*args, &block)
      case args.size
        when 0
          @domain
        when 1
          @domain = parse_domain(args[0])
          self.instance_eval(&block) if block_given?
          self
        when 3
          @domain = parse_domain(args[0])
          @domain_min = parse_domain(args[1])
          @domain_max = parse_domain(args[2])
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end
    alias_method :from, :domain

    def domain_min(*args, &block)
      case args.size
        when 0
          @domain_min
        when 1
          @domain_min = parse_domain(args[0])
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end

    def domain_max(*args, &block)
      case args.size
        when 0
          @domain_max
        when 1
          @domain_max = parse_domain(args[0])
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end

    def range(*args, &block)
      case args.size
        when 0
          @range
        when 1
          @range = parse_range(args[0])
          self.instance_eval(&block) if block_given?
          self
        when 3
          @range = parse_range(args[0])
          @range_min = parse_range(args[1])
          @range_max = parse_range(args[2])
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end
    alias_method :to, :range

    def range_min(*args, &block)
      case args.size
        when 0
          @range_min
        when 1
          @range_min = parse_domain(args[0])
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end

    def range_max(*args, &block)
      case args.size
        when 0
          @range_max
        when 1
          @range_max = parse_domain(args[0])
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end

    def method_missing(method, *args, &block)
      case method.to_s
        when /in_(\w+)s$/ # set @nice for time and utc type, eg. in_seconds
          if TIME_SCALE_NICE.include?($1.to_sym)
            self.nice($1.to_sym, &block)
          else
            super
          end
        when /to_(\w+)$/ # set range literals, eg. to_more_colors
          if RANGE_LITERALS.include?($1.to_sym)
            self.range($1.to_sym, &block)
          else
            super
          end
        else
          super
      end
    end

  private

    def ordinal_scale
      # @!attributes points
      #   @return [Boolean] whether distributes the ordinal values over a
      #     quantitative range at uniformly spaced points or bands
      # @!attributes padding
      #   @return [Numeric] the spacing among ordinal elements in the scale range
      # @!attributes sort
      #   @return [Boolean] whether values in the scale domain will be sorted
      #     according to their natural order
      add_attributes :points, :padding, :sort
      define_boolean_attributes :points, :sort
      define_single_val_attribute :padding
      self.singleton_class.class_eval {
        def bands(&block)
          @points = false
          self.instance_eval(&block) if block
          self
        end
        def bands?
          !@points
        end
        alias_method :as_bands, :bands
        alias_method :as_bands?, :bands?
        alias_method :as_points, :points
        alias_method :as_points?, :points?
      }
    end

    def time_scale
      # @!attributes clamp
      #   @return [Boolean] whether clamps values that exceed the data domain
      #     to either to minimum or maximum range value
      # @!attributes nice
      #   @return [Symbol, Boolean, nil] scale domain in a more human-friendly
      #     value range
      add_attributes :clamp, :nice
      define_boolean_attribute :clamp
      define_single_val_attribute :nice
    end

    def quantitative_scale
      # @!attributes clamp
      #   @return [Boolean] whether clamps values that exceed the data domain
      #     to either to minimum or maximum range value
      # @!attributes nice
      #   @return [Boolean] scale domain in a more human-friendly
      #     value range
      # @!attributes exponent
      #   @return [Numeric] the exponent of the scale transformation
      # @!attributes zero
      #   @return [Boolean] whether zero baseline value is included
      add_attributes :clamp, :exponent, :nice, :zero
      define_boolean_attributes :clamp, :nice, :zero
      define_single_val_attribute :exponent
      self.singleton_class.class_eval {
        alias_method :nicely, :nice
        alias_method :nicely?, :nice?
        alias_method :include_zero, :zero
        alias_method :include_zero?, :zero?
        alias_method :in_exponent, :exponent
      }
    end

    def parse_domain(domain)
      case domain
        when String
          source, field = domain.split('.', 2)
          if field.nil? || field == 'index'
            ::Plotrb::DataRef.new.data(source).field('index')
          else
            ::Plotrb::DataRef.new.data.(source).field("data.#{field}")
          end
        else
          domain
      end
    end

    def parse_range(range)
      case range
        when String, Symbol
          range_literal(range.to_sym)
        else
          range
      end
    end

    def range_literal(literal)
      case literal
        when :colors
          :category10
        when :more_colors
          :category20
        when :width, :height, :shapes
          literal
        else
          raise ArgumentError
      end
    end

    # A data reference specifies the field for a given scale property
    class DataRef

      include ::Plotrb::Base

      # @!attributes data
      #   @return [String] the name of a data set
      # @!attributes field
      #   @return [String] A field from which to pull a data values
      add_attributes :data, :field

      # TODO: Support group
      def initialize(&block)
        data_proc = lambda { |d|
          case d
            when String
              d
            when ::Plotrb::Data
              d.name
            else
              raise ArgumentError
          end
        }
        field_proc = lambda { |f|
          if f.nil? || f == 'index'
            'index'
          else
            "data.#{f}"
          end
        }
        define_single_val_attribute(:data, data_proc)
        define_single_val_attribute(:field, field_proc)
        self.instance_eval(&block) if block
      end

    end

  end

end
