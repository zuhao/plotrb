module Plotrb

  # The container for all visual elements.
  # See {https://github.com/trifacta/vega/wiki/Visualization}
  class Visualization

    include ::Plotrb::Validators
    include ::Plotrb::Base
    include ActiveModel::Validations

    # @!attributes name
    #   @return [String] the name of the visualization
    # @!attributes width
    #   @return [Integer] the total width of the data rectangle
    # @!attributes height
    #   @return [Integer] the total height of the data rectangle
    # @!attributes viewport
    #   @return [Array(Integer, Integer)] the width and height of the viewport
    # @!attributes padding
    #   @return [Integer, Hash] the internal padding from the visualization
    # @!attributes data
    #   @return [Array<Data>] the data for visualization
    # @!attributes scales
    #   @return [Array<Scales>] the scales for visualization
    # @!attributes marks
    #   @return [Array<Marks>] the marks for visualization
    # @!attributes axes
    #   @return [Array<Axis>] the axes for visualization
    add_attributes :name, :width, :height, :viewport, :padding, :data, :scales,
                  :marks, :axes

    def initialize(args={})
      default = {width: 500, height: 500}
      args.reverse_merge(default).each do |k, v|
        self.instance_variable_set("@#{k}", v) if self.attributes.include?(k)
      end
    end

    def method_missing(method, *args, &block)
      if method.to_s =~ /^(\w+)_scale$/
        ::Plotrb::Scale.new(type: $1.to_sym)
      elsif method.to_s =~ /^(x|y)_axis$/
        ::Plotrb::Axis.new(type: $1.to_sym)
      else
        super
      end
    end

    def generate_spec(format=nil)
      if format == :pretty
        JSON.pretty_generate(self.collect_attributes)
      else
        JSON.generate(self.collect_attributes)
      end
    end

    class ViewportValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors.add(attribute, 'invalid viewport') unless
            ::Plotrb::Validators::array_of_integer?(value, 2)
      end
    end

    class PaddingValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors.add(attribute, 'invalid padding') unless
            value.is_a?(Integer) || value.keys.sort == %i(down left right top)
      end
    end

    class DataValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors.add(attribute, 'invalid data') unless
            ::Plotrb::Validators::array_of_data?(value)
      end
    end

    class ScalesValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors.add(attribute, 'invalid scales') unless
            ::Plotrb::Validators::array_of_scale?(value)
      end
    end

    class MarksValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors.add(attribute, 'invalid marks') unless
            ::Plotrb::Validators::array_of_mark?(value)
      end
    end

    class AxesValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors.add(attribute, 'invalid axes') unless
            ::Plotrb::Validators::array_of_axis?(value)
      end
    end

    validates :name, presence: true, length: { minimum: 1 }
    validates :width, presence: true,
              numericality: { only_integer: true, greater_than: 0 }
    validates :height, presence: true,
              numericality: { only_integer: true, greater_than: 0 }
    validates :viewport, presence: true, viewport: true
    validates :padding, presence: true, padding: true
    validates :data, presence: true, length: { minimum: 1 }, data: true
    validates :scales, presence: true, length: { minimum: 1 }, scales: true
    validates :marks, presence: true, length: { minimum: 1 }, marks: true
    validates :axes, presence: true, length: { minimum: 1 }, axes: true

  end

end