module Plotrb

  # Marks are the basic visual building block of a visualization.
  # See {https://github.com/trifacta/vega/wiki/Marks}
  class Mark

    include ::Plotrb::Base

    # all available types of marks defined by Vega
    TYPES = %i(rect symbol path arc area line image text group)

    TYPES.each do |t|
      define_singleton_method(t) do |&block|
        ::Plotrb::Mark.new(t, &block)
      end
    end

    # Top level mark properties

    # @!attributes type
    #   @return [Symbol] the mark type
    # @!attributes name
    #   @return [String] the name of the mark
    # @!attributes description
    #   @return [String] optional description of the mark
    # @!attributes from
    #   @return [Hash] the data this mark set should visualize
    # @!attributes properties
    #   @return [MarkProperty] the property set definitions
    # @!attributes key
    #   @return [String] the data field to use an unique key for data binding
    # @!attributes delay
    #   @return [ValueRef] the transition delay for mark updates
    # @!attributes ease
    #   @return [String] the transition easing function for mark updates
    MARK_PROPERTIES = [:type, :name, :description, :from, :properties, :key,
                       :delay, :ease, :group]

    add_attributes *MARK_PROPERTIES

    def initialize(type, &block)
      @type = type
      @properties = {}
      define_single_val_attributes(:name, :description, :key, :delay, :ease,
                                   :group)
      define_multi_val_attributes(:from)
      if @type == :group
        add_attributes(:scales, :axes, :marks)
        define_multi_val_attributes(:scales, :axes, :marks)
      end
      ::Plotrb::Kernel.marks << self
      self.instance_eval(&block) if block_given?
      self
    end

    def type
      @type
    end

    def properties
      @properties
    end

    def enter(&block)
      process_from
      data = @from[:data] if @from
      @properties.merge!(
          { enter: ::Plotrb::Mark::MarkProperty.
              new(@type, data, &block) }
      )
      self
    end

    def exit(&block)
      process_from
      data = @from[:data] if @from
      @properties.merge!(
          { exit: ::Plotrb::Mark::MarkProperty.
              new(@type, data, &block) }
      )
      self
    end

    def update(&block)
      process_from
      data = @from[:data] if @from
      @properties.merge!(
          { update: ::Plotrb::Mark::MarkProperty.
              new(@type, data, &block) }
      )
      self
    end

    def hover(&block)
      process_from
      data = @from[:data] if @from
      @properties.merge!(
          { hover: ::Plotrb::Mark::MarkProperty.
              new(@type, data, &block) }
      )
      self
    end

  private

    def attribute_post_processing
      process_name
      process_from
      process_group
    end

    def process_name
      return unless @name
      if ::Plotrb::Kernel.duplicate_mark?(@name)
        raise ArgumentError, 'Duplicate Mark name'
      end
    end

    def process_from
      return unless @from && !@from_processed
      from = {}
      @from.each do |f|
        case f
          when String
            if ::Plotrb::Kernel.find_data(f)
              from[:data] = f
            else
              raise ArgumentError, 'Invalid data for Mark from'
            end
          when ::Plotrb::Data
            from[:data] = f.name
          when ::Plotrb::Transform
            from[:transform] ||= []
            from[:transform] << f
          else
            raise ArgumentError, 'Invalid Mark from'
        end
      end
      @from = from
      @from_processed = true
    end

    def process_group
      return unless @scales
      unless @scales.all? { |s| s.is_a?(::Plotrb::Scale) }
        raise ArgumentError, 'Invalid scales for group mark'
      end

      return unless @axes
      unless @axes.all? { |s| s.is_a?(::Plotrb::Axis) }
        raise ArgumentError, 'Invalid axes for group mark'
      end

      return unless @marks
      unless @marks.all? { |s| s.is_a?(::Plotrb::Mark) }
        raise ArgumentError, 'Invalid marks for group mark'
      end
    end

    class MarkProperty

      include ::Plotrb::Base

      # Shared visual properties

      # @!attributes x
      #   @return [ValueRef] the first (left-most) x-coordinate
      # @!attributes x2
      #   @return [ValueRef] the second (right-most) x-coordinate
      # @!attributes width
      #   @return [ValueRef] the width of the mark
      # @!attributes y
      #   @return [ValueRef] the first (top-most) y-coordinate
      # @!attributes y2
      #   @return [ValueRef] the second (bottom-most) y-coordinate
      # @!attributes height
      #   @return [ValueRef] the height of the mark
      # @!attributes opacity
      #   @return [ValueRef] the overall opacity
      # @!attributes fill
      #   @return [ValueRef] the fill color
      # @!attributes fill_opacity
      #   @return [ValueRef] the fill opacity
      # @!attributes stroke
      #   @return [ValueRef] the stroke color
      # @!attributes stroke_width
      #   @return [ValueRef] the stroke width in pixels
      # @!attributes stroke_opacity
      #   @return [ValueRef] the stroke opacity
      # @!attributes stroke_dash
      #   @return [ValueRef] alternating stroke, space lengths for creating dashed
      #     or dotted lines
      # @!attributes stroke_dash_offset
      #   @return [ValueRef] the offset into which to begin the stroke dash
      VISUAL_PROPERTIES = [:x, :x2, :width, :y, :y2, :height, :opacity, :fill,
                           :fill_opacity, :stroke, :stroke_width,
                           :stroke_opacity, :stroke_dash, :stroke_dash_offset]

      add_attributes *VISUAL_PROPERTIES
      attr_reader :data

      def initialize(type, data=nil, &block)
        define_single_val_attributes *VISUAL_PROPERTIES
        self.singleton_class.class_eval {
          alias_method :x_start, :x
          alias_method :left, :x
          alias_method :x_end, :x2
          alias_method :right, :x2
          alias_method :y_start, :y
          alias_method :top, :y
          alias_method :y_end, :y2
          alias_method :bottom, :y2
        }
        @data = data
        self.send(type)
        self.instance_eval(&block) if block_given?
      end

    private

      def attribute_post_processing

      end

      def rect
        # no additional attributes
      end

      def group
        # no additional attributes
      end

      def symbol
        # @!attribute size
        #   @return [ValueRef] the pixel area of the symbol
        # @!attribute shape
        #   @return [ValueRef] the symbol shape
        attrs = [:size, :shape]
        add_attributes *attrs
        define_single_val_attributes *attrs
      end

      def path
        # @!attribute path
        #   @return [ValueRef] the path definition in SVG path string
        attrs = [:path]
        add_attributes *attrs
        define_single_val_attribute *attrs
      end

      def arc
        # @!attribute inner_radius
        #   @return [ValueRef] the inner radius of the arc in pixels
        # @!attribute outer_radius
        #   @return [ValueRef] the outer radius of the arc in pixels
        # @!attribute start_angle
        #   @return [ValueRef] the start angle of the arc in radians
        # @!attribute end_angle
        #   @return [ValueRef] the end angle of the arc in radians
        attrs = [:inner_radius, :outer_radius, :start_angle, :end_angle]
        add_attributes *attrs
        define_single_val_attributes *attrs
      end

      def area
        # @!attribute interpolate
        #   @return [ValueRef] the line interpolation method to use
        # @!attribute tension
        #   @return [ValueRef] the tension parameter for the interpolation
        attrs = [:interpolate, :tension]
        add_attributes *attrs
        define_single_val_attributes *attrs
      end

      def line
        # @!attribute interpolate
        #   @return [ValueRef] the line interpolation method to use
        # @!attribute tension
        #   @return [ValueRef] the tension parameter for the interpolation
        attrs = [:interpolate, :tension]
        add_attributes *attrs
        define_single_val_attributes *attrs
      end

      def image
        # @!attribute url
        #   @return [ValueRef] the url from which to retrieve the image
        # @!attribute align
        #   @return [ValueRef] the horizontal alignment of the image
        # @!attribute baseline
        #   @return [ValueRef] the vertical alignment of the image
        attrs = [:url, :align, :baseline]
        add_attributes *attrs
        define_single_val_attributes *attrs
      end

      def text
        # @!attribute text
        #   @return [ValueRef] the text to display
        # @!attribute align
        #   @return [ValueRef] the horizontal alignment of the text
        # @!attribute baseline
        #   @return [ValueRef] the vertical alignment of the text
        # @!attribute dx
        #   @return [ValueRef] the horizontal margin between text label and its
        #     anchor point
        # @!attribute dy
        #   @return [ValueRef] the vertical margin between text label and its
        #     anchor point
        # @!attribute angle
        #   @return [ValueRef] the rotation angle of the text in degrees
        # @!attribute font
        #   @return [ValueRef] the font of the text
        # @!attribute font_size
        #   @return [ValueRef] the font size
        # @!attribute font_weight
        #   @return [ValueRef] the font weight
        # @!attribute font_style
        #   @return [ValueRef] the font style
        attrs = [:text, :align, :baseline, :dx, :dy, :angle, :font, :font_size,
                 :font_weight, :font_style]
        add_attributes *attrs
        define_single_val_attributes *attrs
      end

      def define_single_val_attribute(method)
        define_singleton_method(method) do |*args, &block|
          if block
            val = ::Plotrb::Mark::MarkProperty::ValueRef.
                new(@data, *args, &block)
            self.instance_variable_set("@#{method}", val)
          else
            case args.size
              when 0
                self.instance_variable_get("@#{method}")
              when 1
                val = ::Plotrb::Mark::MarkProperty::ValueRef.new(@data, args[0])
                self.instance_variable_set("@#{method}", val)
              else
                raise ArgumentError
            end
          end
          self
        end
      end

      def define_single_val_attributes(*method)
        method.each { |m| define_single_val_attribute(m) }
      end

      # A value reference specifies the value for a given mark property
      class ValueRef

        include ::Plotrb::Base

        # @!attributes value
        #   @return A constant value
        # @!attributes field
        #   @return [String] A field from which to pull a data value
        # @!attributes scale
        #   @return [String] the name of a scale transform to apply
        # @!attributes mult
        #   @return [Numeric] a multiplier for the value
        # @!attributes offset
        #   @return [Numeric] an additive offset to bias the final value
        # @!attributes band
        #   @return [Boolean] whether to use range band of the scale as the
        #     retrieved value
        VALUE_REF_PROPERTIES = [:value, :field, :scale, :mult, :offset, :band,
                                :group]

        add_attributes *VALUE_REF_PROPERTIES
        attr_reader :data

        def initialize(data, value=nil, &block)
          @data = data
          define_single_val_attributes(:value, :mult, :offset, :group, :field,
                                       :scale)
          define_boolean_attribute(:band)
          self.singleton_class.class_eval {
            alias_method :from, :field
            alias_method :use_band, :band
            alias_method :use_band?, :band?
            alias_method :times, :mult
          }
          if value
            @value = value
          end
          self.instance_eval(&block) if block
          self
        end

      private

        def attribute_post_processing
          process_scale
          process_field
        end

        def process_field
          return unless @field
          case @field
            when String, Symbol
              @field = get_full_field_ref(@field)
            when Hash
              if @field[:group]
                @field[:group] = get_full_field_ref(@field[:group])
              else
                raise ArgumentError, 'Missing field group'
              end
            else
              raise ArgumentError, 'Invalid value field'
          end
        end

        def process_scale
          return unless @scale
          case @scale
            when String
              unless ::Plotrb::Kernel.find_scale(@scale)
                raise ArgumentError, 'Invalid value scale'
              end
            when ::Plotrb::Scale
              @scale = @scale.name
            when Hash
              if @scale[:field]
                @scale[:field] = get_full_field_ref(@scale[:field])
              end
              if @scale[:group]
                @scale[:group] = get_full_field_ref(@scale[:group])
              end
            else
              raise ArgumentError, 'Invalid value scale'
          end
        end

        def get_full_field_ref(field)
          data = if @data.is_a?(::Plotrb::Data)
                   @data
                 else
                   ::Plotrb::Kernel.find_data(@data)
                 end
          extra_fields = (data.extra_fields if data) || []
          if field.to_s.start_with?('data.')
            field
          elsif extra_fields.include?(field.to_sym)
            classify(field, :json)
          else
            "data.#{field}"
          end
        end

      end

    end

  end

end
