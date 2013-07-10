module Plotrb

  # Axes provide axis lines, ticks, and labels to convey how a spatial range
  #   represents a data range.
  # See {https://github.com/trifacta/vega/wiki/Axes}
  class Axis

    include ::Plotrb::Internals
    include ActiveModel::Validations

    # @!attribute [rw] type
    #   @return [Symbol] type of the axis, either :x or :y
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

  end

end