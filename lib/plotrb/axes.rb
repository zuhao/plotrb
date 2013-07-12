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
                  :tick_size_end, :offset, :properties

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

  end

end