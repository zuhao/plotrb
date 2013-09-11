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

    # @!attributes type
    #   @return [Symbol] the type of the scale
    SCALE_PROPERTIES = [:name, :type, :domain, :domain_min, :domain_max, :range,
                        :range_min, :range_max, :reverse, :round]

    add_attributes *SCALE_PROPERTIES

    RANGE_LITERALS = %i(width height shapes colors more_colors)
    TIME_SCALE_NICE = %i(second minute hour day week month year)

    def initialize(type=:linear, &block)
      @type = type
      case @type
        when :ordinal
          set_ordinal_scale_attributes
        when :time, :utc
          set_time_scale_attributes
        else
          set_quantitative_scale_attributes
      end
      set_common_scale_attributes
      ::Plotrb::Kernel.scales << self
      self.instance_eval(&block) if block_given?
      self
    end

    def type
      @type
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

    def set_common_scale_attributes
      # @!attributes name
      #   @return [String] the name of the scale
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
      define_single_val_attributes(:name, :domain, :domain_max, :domain_min,
                                   :range, :range_max, :range_min)
      define_boolean_attributes(:reverse, :round)
      self.singleton_class.class_eval {
        alias_method :from, :domain
        alias_method :to, :range
      }
    end

    def set_ordinal_scale_attributes
      # @!attributes points
      #   @return [Boolean] whether distributes the ordinal values over a
      #     quantitative range at uniformly spaced points or bands
      # @!attributes padding
      #   @return [Numeric] the spacing among ordinal elements in the scale range
      # @!attributes sort
      #   @return [Boolean] whether values in the scale domain will be sorted
      #     according to their natural order
      add_attributes(:points, :padding, :sort)
      define_boolean_attributes(:points, :sort)
      define_single_val_attribute(:padding)
      define_singleton_method(:bands) do |&block|
        @points = false
        self.instance_eval(&block) if block
        self
      end
      define_singleton_method(:bands?) do
        !@points
      end
      self.singleton_class.class_eval {
        alias_method :as_bands, :bands
        alias_method :as_bands?, :bands?
        alias_method :as_points, :points
        alias_method :as_points?, :points?
      }
    end

    def set_time_scale_attributes
      # @!attributes clamp
      #   @return [Boolean] whether clamps values that exceed the data domain
      #     to either to minimum or maximum range value
      # @!attributes nice
      #   @return [Symbol, Boolean, nil] scale domain in a more human-friendly
      #     value range
      add_attributes(:clamp, :nice)
      define_boolean_attribute(:clamp)
      define_single_val_attribute(:nice)
    end

    def set_quantitative_scale_attributes
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
      add_attributes(:clamp, :exponent, :nice, :zero)
      define_boolean_attributes(:clamp, :nice, :zero)
      define_single_val_attribute(:exponent)
      define_singleton_method(:exclude_zero) do |&block|
        @zero = false
        self.instance_eval(&block) if block
        self
      end
      define_singleton_method(:exclude_zero?) do
        !@zero
      end
      self.singleton_class.class_eval {
        alias_method :nicely, :nice
        alias_method :nicely?, :nice?
        alias_method :include_zero, :zero
        alias_method :include_zero?, :zero?
        alias_method :in_exponent, :exponent
      }
    end

    def attribute_post_processing
      process_name
      process_type
      process_domain
      process_domain_min
      process_domain_max
      process_range
    end

    def process_name
      if @name.nil? || @name.strip.empty?
        raise ArgumentError, 'Name missing for Scale object'
      end
      if ::Plotrb::Kernel.duplicate_scale?(@name)
        raise ArgumentError, 'Duplicate names for Scale object'
      end
    end

    def process_type
      unless TYPES.include?(@type)
        raise ArgumentError, 'Invalid Scale type'
      end
    end

    def process_domain
      return unless @domain
      case @domain
        when String
          @domain = get_data_ref_from_string(@domain)
        when ::Plotrb::Data
          @domain = get_data_ref_from_data(@domain)
        when Array
          if @domain.all? { |d| is_data_ref?(d) }
            fields = @domain.collect { |d| get_data_ref_from_string(d) }
            @domain = {:fields => fields}
          else
            # leave as it is
          end
        else
          raise ArgumentError, 'Unsupported Scale domain type'
      end
    end

    def process_domain_min
      return unless @domain_min && !%i(ordinal time utc).include?(@type)
      case @domain_min
        when String
          @domain_min = get_data_ref_from_string(@domain_min)
        when ::Plotrb::Data
          @domain_min = get_data_ref_from_data(@domain_min)
        when Array
          if @domain_min.all? { |d| is_data_ref?(d) }
            fields = @domain_min.collect { |d| get_data_ref_from_string(d) }
            @domain_min = {:fields => fields}
          else
            raise ArgumentError, 'Unsupported Scale domain_min type'
          end
        when Numeric
          # leave as it is
        else
          raise ArgumentError, 'Unsupported Scale domain_min type'
      end
    end

    def process_domain_max
      return unless @domain_max && !%i(ordinal time utc).include?(@type)
      case @domain_max
        when String
          @domain_max = get_data_ref_from_string(@domain_max)
        when ::Plotrb::Data
          @domain_max = get_data_ref_from_data(@domain_max)
        when Array
          if @domain_max.all? { |d| is_data_ref?(d) }
            fields = @domain_max.collect { |d| get_data_ref_from_string(d) }
            @domain_max = {:fields => fields}
          else
            raise ArgumentError, 'Unsupported Scale domain_max type'
          end
        when Numeric
          # leave as it is
        else
          raise ArgumentError, 'Unsupported Scale domain_max type'
      end
    end

    def get_data_ref_from_string(ref)
      source, field = ref.split('.', 2)
      data = ::Plotrb::Kernel.find_data(source)
      if field.nil?
        if data && data.values.is_a?(Array)
          ::Plotrb::Scale::DataRef.new.data(source).field('data')
        else
          ::Plotrb::Scale::DataRef.new.data(source).field('index')
        end
      elsif field == 'index'
        ::Plotrb::Scale::DataRef.new.data(source).field('index')
      else
        if data.extra_fields.include?(field.to_sym)
          ::Plotrb::Scale::DataRef.new.data(source).field(field)
        else
          ::Plotrb::Scale::DataRef.new.data(source).field("data.#{field}")
        end
      end
    end

    def get_data_ref_from_data(data)
      if data.values.is_a?(Array)
        ::Plotrb::Scale::DataRef.new.data(data.name).field('data')
      else
        ::Plotrb::Scale::DataRef.new.data(data.name).field('index')
      end
    end

    def is_data_ref?(ref)
      source, _ = ref.split('.', 2)
      not ::Plotrb::Kernel.find_data(source).nil?
    end

    def process_range
      return unless @range
      case @range
        when String, Symbol
          @range = range_literal(@range)
        when Array
          #leave as it is
        else
          raise ArgumentError, 'Unsupported Scale range type'
      end
    end

    def range_literal(literal)
      case literal
        when :colors
          :category10
        when :more_colors
          :category20
        when :width, :height, :shapes, :category10, :category20
          literal
        else
          raise ArgumentError, 'Invalid Scale range'
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
        define_single_val_attributes(:data, :field)
        self.instance_eval(&block) if block
        self
      end

    private

      def attribute_post_processing

      end

    end

  end

end
