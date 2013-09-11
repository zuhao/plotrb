module Plotrb

  # Axes provide axis lines, ticks, and labels to convey how a spatial range
  #   represents a data range.
  # See {https://github.com/trifacta/vega/wiki/Axes}
  class Axis

    include ::Plotrb::Base

    TYPES = %i(x y)

    TYPES.each do |t|
      define_singleton_method(t) do |&block|
        ::Plotrb::Axis.new(t, &block)
      end
    end

    # @!attribute type
    #   @return [Symbol] type of the axis, either :x or :y
    # @!attribute scale
    #   @return [String] the name of the scale backing the axis
    # @!attribute orient
    #   @return [Symbol] the orientation of the axis
    # @!attribute format
    #   @return [String] the formatting pattern for axis labels
    # @!attribute ticks
    #   @return [Integer] a desired number of ticks
    # @!attribute values
    #   @return [Array] explicitly set the visible axis tick values
    # @!attribute subdivide
    #   @return [Integer] the number of minor ticks between major ticks
    # @!attribute tick_padding
    #   @return [Integer] the padding between ticks and text labels
    # @!attribute tick_size
    #   @return [Integer] the size of major, minor, and end ticks
    # @!attribute tick_size_major
    #   @return [Integer] the size of major ticks
    # @!attribute tick_size_minor
    #   @return [Integer] the size of minor ticks
    # @!attribute tick_size_end
    #   @return [Integer] the size of end ticks
    # @!attribute offset
    #   @return [Integer] the offset by which to displace the axis from the edge
    #     of the enclosing group or data rectangle
    # @!attribute properties
    #   @return [Hash] optional mark property definitions for custom styling
    # @!attribute title
    #   @return [String] the title for the axis
    # @!attribute tittle_offset
    #   @return [Integer] the offset from the axis at which to place the title
    # @!attribute grid
    #   @return [Boolean] whether gridlines should be created
    add_attributes :type, :scale, :orient, :format, :ticks, :values, :subdivide,
                  :tick_padding, :tick_size, :tick_size_major, :tick_size_minor,
                  :tick_size_end, :offset, :layer, :properties, :title,
                  :title_offset, :grid

    def initialize(type, &block)
      @type = type
      define_single_val_attributes(:scale, :orient, :title, :title_offset,
                                   :format, :ticks, :subdivide, :tick_padding,
                                   :tick_size, :tick_size_major, :tick_size_end,
                                   :tick_size_minor, :offset, :layer)
      define_boolean_attribute(:grid)
      define_multi_val_attributes(:values)
      self.singleton_class.class_eval {
        alias_method :from, :scale
        alias_method :offset_title_by, :title_offset
        alias_method :subdivide_by, :subdivide
        alias_method :major_tick_size, :tick_size_major
        alias_method :minor_tick_size, :tick_size_minor
        alias_method :end_tick_size, :tick_size_end
        alias_method :offset_by, :offset
        alias_method :show_grid, :grid
        alias_method :with_grid, :grid
        alias_method :show_grid?, :grid?
        alias_method :with_grid?, :grid?
      }
      self.instance_eval(&block) if block_given?
      ::Plotrb::Kernel.axes << self
      self
    end

    def above(&block)
      @layer = :front
      self.instance_eval(&block) if block_given?
      self
    end

    def above?
      @layer == :front
    end

    def below(&block)
      @layer = :back
      self.instance_eval(&block) if block_given?
      self
    end

    def below?
      @layer == :back
    end

    def no_grid(&block)
      @grid = false
      self.instance_eval(&block) if block
      self
    end

    def properties(element=nil, &block)
      @properties ||= {}
      return @properties unless element
      @properties.merge!(
          element.to_sym => ::Plotrb::Mark::MarkProperty.new(:text, &block)
      )
      self
    end

    def method_missing(method, *args, &block)
      case method.to_s
        when /^with_(\d+)_ticks$/  # set number of ticks. eg. in_20_ticks
          self.ticks($1.to_i, &block)
        when /^subdivide_by_(\d+)$/ # set subdivide of ticks
          self.subdivide($1.to_i, &block)
        when /^at_(top|bottom|left|right)$/ # set orient of the axis
          self.orient($1.to_sym, &block)
        when /^in_(front|back)$/ # set layer of the axis
          self.layer($1.to_sym, &block)
        else
          super
      end
    end

  private

    def attribute_post_processing
      process_type
      process_scale
      process_orient
      process_format
      process_layer
      process_properties
    end

    def process_type
      unless TYPES.include?(@type)
        raise ArgumentError, 'Invalid Axis type'
      end
    end

    def process_scale
      return unless @scale
      case @scale
        when String
          unless ::Plotrb::Kernel.find_scale(@scale)
            raise ArgumentError, 'Scale not found'
          end
        when ::Plotrb::Scale
          @scale = @scale.name
        else
          raise ArgumentError, 'Unknown Scale'
      end
    end

    def process_orient
      return unless @orient
      unless %i(top bottom left right).include?(@orient.to_sym)
        raise ArgumentError, 'Invalid Axis orient'
      end
    end

    def process_format
      return unless @format
      # D3's format specifier has general form:
      # [​[fill]align][sign][symbol][0][width][,][.precision][type]
      # the regex is taken from d3/src/format/format.js
      re =
        /(?:([^{])?([<>=^]))?([+\- ])?([$#])?(0)?(\d+)?(,)?(\.-?\d+)?([a-z%])?/i
      @format = @format.to_s
      if @format =~ re
        if "#{$1}#{$2}#{$3}#{$4}#{$5}#{$6}#{$7}#{$8}#{$9}" != @format
          raise ArgumentError, 'Invalid format specifier'
        end
      end
    end

    def process_layer
      return unless @layer
      unless %i(front back).include?(@layer.to_sym)
        raise ArgumentError, 'Invalid Axis layer'
      end
    end

    def process_properties
      return unless @properties
      valid_elements = %i(ticks major_ticks minor_ticks grid labels axis)
      unless (@properties.keys - valid_elements).empty?
        raise ArgumentError, 'Invalid property element'
      end
    end

  end

end
