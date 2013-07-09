module Plotrb

  # Marks are the basic visual building block of a visualization.
  # See {https://github.com/trifacta/vega/wiki/Marks}
  class Mark

    include ActiveModel::Validations

    TYPES = %i(rect symbol path arc area line image text)

    attr_accessor :type, :name, :description, :from, :properties, :key, :delay,
                  :ease

    class FromValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors.add(attribute, 'invalid object') unless
            valid_from?(value)
      end

      def valid_from?(from)
        (from.keys - %i(data transform)).empty?
      rescue NoMethodError
        false
      end
    end

    class EaseValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors.add(attribute, 'invalid easing function') unless
            valid_easing?(value)
      end

      def valid_easing?(easing)
        # a valid easing function is type-modifier, such as cubic-in
        type, modifier = easing.split('-', 2)
        %w(linear quad cubic sin exp circle bounce).include?(type) &&
            (modifier.nil? || %w(in out in-out out-in).include?(modifier))
      end
    end

    validates :type, presence: true, inclusion: { in: TYPES }
    validates :from, presence: true, from: true
    #validates :properties, allow_nil: true
    validates :ease, allow_nil: true, ease: true

    # A value reference specifies the value for a given mark property
    class ValueRef

      include ActiveModel::Validations

      attr_accessor :value, :field, :scale, :mult, :offset, :band

      validates :mult, allow_nil: true, numericality: true
      validates :offset, allow_nil: true, numericality: true

    end

    # Mark property sets
    attr_accessor :x, :x2, :width, :y, :y2, :height, :opacity, :fill,
                  :fill_opacity, :stroke, :stroke_width, :stroke_opacity, :size,
                  :shape, :path, :inner_radius, :outer_radius, :start_angle,
                  :end_angle, :interpolate, :tension, :url, :align, :baseline,
                  :text, :align, :dx, :dy, :angle, :font, :font_size,
                  :font_weight, :font_style

    class ValueReferenceValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors.add(attribute, 'invalid ValueRef') unless
            value.is_a?(::Plotrb::Mark::ValueRef) && value.valid?
      end
    end
  end

end