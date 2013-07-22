module Plotrb

  # Axes provide axis lines, ticks, and labels to convey how a spatial range
  #   represents a data range.
  # See {https://github.com/trifacta/vega/wiki/Axes}
  class Axis

    include ::Plotrb::Internals
    include ActiveModel::Validations

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
    attr_accessor :type, :scale, :orient, :format, :ticks, :values, :subdivide,
                  :tick_padding, :tick_size, :tick_size_major, :tick_size_minor,
                  :tick_size_end, :offset, :properties, :title, :title_offset,
                  :grid

    # TODO: validates properties object using standard Vega Value References
    class PropertiesValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors.add(attribute, 'invalid properties for axis') unless
            valid_keys?(value)
      end

      def valid_keys?(prop)
        (prop.keys - %i(ticks major_ticks minor_ticks labels axis)).empty?
      rescue NoMethodError
        false
      end
    end

    validates :type, presence: true, inclusion: { in: %i(x y) }
    validates :scale, presence: true
    validates :orient, inclusion: { in: %i(top bottom left right) },
              allow_nil: true
    validates :ticks, numericality: { only_integer: true, greater_than: 0 },
              allow_nil: true
    validates :subdivide, numericality: { only_integer: true, greater_than: 0 },
              allow_nil: true
    validates :tick_padding, allow_nil: true,
              numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :tick_size, allow_nil: true,
              numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :tick_size_major, allow_nil: true,
              numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :tick_size_minor, allow_nil: true,
              numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :tick_size_end, allow_nil: true,
              numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :offset, allow_nil: true,
              numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :properties, allow_nil: true, properties: true

    def initialize(args={})
      args.each do |k, v|
        self.instance_variable_set("@#{k}", v) if self.attributes.include?(k)
      end
    end

    def from(scale)
      @scale =
          case scale
            when ::Plotrb::Scale
              @scale = scale.name
            when String
              @scale = scale
            else
              nil
          end
      self
    end

    def ticks(ticks)
      @ticks = ticks.to_i
      self
    end

    def subdivide_by(divide)
      @subdivide = divide.to_i
      self
    end

    def orient(*args)
      case args.size
        when 0
          @orient
        when 1
          @orient = args.first.to_sym
          self
        else
          nil
      end
    end

    def title(title, offset=nil)
      @title = title
      @title_offset = offset if offset
      self
    end

    def offset_title_by(offset)
      @title_offset = offset
      self
    end

    def format(format)
      @format = format
      self
    end

    def values(values)
      @values = values
      self
    end

    def layer(layer)
      @layer = layer
      self
    end

    def with_grid
      @grid = true
      self
    end
    alias_method :show_grid, :with_grid



    def method_missing(method, *args, &block)
      case method.to_s
        when /^(\w+)\?$/ # return value of the attribute, eg. type?
          if attributes.include?($1.to_sym)
            self.instance_variable_get("@#{$1.to_sym}")
          else
            super
          end
        when /^in_(\d+)_ticks$/  # set number of ticks. eg. in_20_ticks
          self.ticks($1.to_i)
        when /^subdivide_by_(\d+)$/ # set subdivide of ticks
          self.subdivide($1.to_i)
        when /^at_(top|bottom|left|right)$/ # set orient of the axis
          self.orient($1.to_sym)
        when /^at_(front|back)$/ # set layer of the axis
          self.layer($1.to_sym)
        else
          super
      end
    end

  end

end