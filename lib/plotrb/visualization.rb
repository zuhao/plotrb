module Plotrb

  # The container for all visual elements.
  # See {https://github.com/trifacta/vega/wiki/Visualization}
  class Visualization

    include ::Plotrb::Base
    include ::Plotrb::Kernel

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

    def initialize(&block)
      define_single_val_attributes(:name, :width, :height, :viewport, :padding)
      define_multi_val_attributes(:data, :scales, :marks, :axes)
      self.instance_eval(&block) if block_given?
    end

    def generate_spec(format=nil)
      if format == :pretty
        JSON.pretty_generate(self.collect_attributes)
      else
        JSON.generate(self.collect_attributes)
      end
    end

  private

    def attribute_post_processing

    end

  end

end
