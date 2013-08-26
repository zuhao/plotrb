module Plotrb

  # Marks are the basic visual building block of a visualization.
  # See {https://github.com/trifacta/vega/wiki/Marks}
  class Mark

    include ::Plotrb::Base
    include ActiveModel::Validations

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
    #   @return [Hash] the property set definitions
    # @!attributes key
    #   @return [String] the data field to use an unique key for data binding
    # @!attributes delay
    #   @return [ValueRef] the transition delay for mark updates
    # @!attributes ease
    #   @return [String] the transition easing function for mark updates
    add_attributes :type, :name, :description, :from, :properties, :key, :delay,
                   :ease, :group

    class FromValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors.add(attribute, 'invalid object') unless
            valid_from?(value)
      end
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
    add_attributes :x, :x2, :width, :y, :y2, :height, :opacity, :fill,
                   :fill_opacity, :stroke, :stroke_width, :stroke_opacity,
                   :stroke_dash, :stroke_dash_offset

    def initialize(type, &block)
      @type = type
      self.send(@type)
      define_single_val_attributes(:name, :description, :from, :properties,
                                   :key, :delay, :ease, :group)
      define_single_val_attributes(:x, :x2, :width, :y, :y2, :height, :opacity,
                                   :fill, :fill_opacity, :stroke, :stroke_width,
                                   :stroke_opacity, :stroke_dash,
                                   :stroke_dash_offset)
      self.instance_eval(&block) if block_given?
    end

      def valid_from?(from)
        (from.keys - %i(data transform)).empty?
      rescue NoMethodError
        false
      end
    def type
      @type
    end

    class EaseValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors.add(attribute, 'invalid easing function') unless
            valid_easing?(value)
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
      add_attributes(:size, :shape)
      define_single_val_attributes(:size, :shape)
    end

    def path
      # @!attribute path
      #   @return [ValueRef] the path definition in SVG path string
      add_attributes(:path)
      define_single_val_attribute(:path)
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
      add_attributes(:inner_radius, :outer_radius, :start_angle, :end_angle)
      define_single_val_attributes(:inner_radius, :outer_radius, :start_angle,
                                  :end_angle)
    end

    def area
      # @!attribute interpolate
      #   @return [ValueRef] the line interpolation method to use
      # @!attribute tension
      #   @return [ValueRef] the tension parameter for the interpolation
      add_attributes(:interpolate, :tension)
      define_single_val_attributes(:interpolate, :tension)
    end

    def line
      # @!attribute interpolate
      #   @return [ValueRef] the line interpolation method to use
      # @!attribute tension
      #   @return [ValueRef] the tension parameter for the interpolation
      add_attributes(:interpolate, :tension)
      define_single_val_attributes(:interpolate, :tension)
    end

    def image
      # @!attribute url
      #   @return [ValueRef] the url from which to retrieve the image
      # @!attribute align
      #   @return [ValueRef] the horizontal alignment of the image
      # @!attribute baseline
      #   @return [ValueRef] the vertical alignment of the image
      add_attributes(:url, :align, :baseline)
      define_single_val_attributes(:url, :align, :baseline)
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
      add_attributes(:text, :align, :baseline, :dx, :dy, :angle, :font,
                     :font_size, :font_weight, :font_style)
      define_single_val_attributes(:text, :align, :baseline, :dx, :dy, :angle,
                                   :font, :font_size, :font_weight, :font_style)
    end

  end

  # A value reference specifies the value for a given mark property
  class ValueRef

    include ::Plotrb::Base
    include ActiveModel::Validations

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
    add_attributes :value, :field, :scale, :mult, :offset, :band

    validates :mult, allow_nil: true, numericality: true
    validates :offset, allow_nil: true, numericality: true

    def initialize(args={})
      args.each do |k, v|
        self.instance_variable_set("@#{k}", v) if self.attributes.include?(k)
      end
    end

  end

end