module Plotrb

  # The container for all visual elements.
  # See {https://github.com/trifacta/vega/wiki/Visualization}
  class Visualization

    include ::Plotrb::Base

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

    def initialize(args={}, &block)
      default = {width: 500, height: 500}
      args.reverse_merge(default).each do |k, v|
        self.instance_variable_set("@#{k}", v) if self.attributes.include?(k)
      end
      define_single_val_attributes(:name, :width, :height, :viewport, :padding)
      define_multi_val_attributes(:data, :scales, :marks, :axes)
      self.instance_eval(&block) if block_given?
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

    def x_axis
      ::Plotrb::Axis.new(:x)
    end

    def y_axis
      ::Plotrb::Axis.new(:y)
    end

  end

end
