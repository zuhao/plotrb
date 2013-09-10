module Plotrb

  # Marks are the basic visual building block of a visualization.
  # See {https://github.com/trifacta/vega/wiki/Marks}
  class Mark

    include ::Plotrb::Base

    # all available types of marks defined by Vega
    TYPES = %i(rect symbol path arc area line image text)

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
      self.send(@type)
      @properties = {}
      define_single_val_attributes *(MARK_PROPERTIES - [:type, :properties])
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
      @properties.merge!(
          { enter: ::Plotrb::Mark::MarkProperty.new(&block) }
      )
      self
    end

    def exit(&block)
      @properties.merge!(
          { exit: ::Plotrb::Mark::MarkProperty.new(&block) }
      )
      self
    end

    def update(&block)
      @properties.merge!(
          { update: ::Plotrb::Mark::MarkProperty.new(&block) }
      )
      self
    end

    def hover(&block)
      @properties.merge!(
          { hover: ::Plotrb::Mark::MarkProperty.new(&block) }
      )
      self
    end

  private

    def rect
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

      def initialize(&block)
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
        self.instance_eval(&block) if block_given?
      end

      def define_single_val_attribute(method)
        define_singleton_method(method) do |*args, &block|
          if block
            val = ::Plotrb::Mark::MarkProperty::ValueRef.new(*args, &block)
            self.instance_variable_set("@#{method}", val)
          else
            case args.size
              when 0
                self.instance_variable_get("@#{method}")
              when 1
                val = ::Plotrb::Mark::MarkProperty::ValueRef.new(args[0])
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
        VALUE_REF_PROPERTIES = [:value, :field, :scale, :mult, :offset, :band]

        add_attributes *VALUE_REF_PROPERTIES

        def initialize(value=nil, &block)
          define_single_val_attributes(:value, :field, :scale, :mult, :offset)
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
        end

      end

    end

  end

end
