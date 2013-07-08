module Plotrb

  # The container for all visual elements.
  # See {https://github.com/trifacta/vega/wiki/Visualization}
  class Visualization

    include ::Plotrb::Validators

    attr_accessor :name, :width, :height, :viewport, :padding, :data, :scales,
                  :marks

    def initialize(args={})
      @name     = args[:name]
      @width    = args[:width] || 500
      @height   = args[:height] || 500
      @viewport = args[:viewport] || [@width, @height]
      @padding  = args[:padding] || 5
    end

    # @param name [String] unique name of the visualization
    def name=(name)
      @name = name.to_s
      raise ::Plotrb::InvalidInputError if @name.empty?
    end

    # @param width [Integer] the total width of the data rectangle
    def width=(width)
      if width.respond_to?(:to_i)
        @width = width.to_i
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # @param height [Integer] the total height of the data rectangle
    def height=(height)
      if height.respond_to?(:to_i)
        @height = height.to_i
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # @param viewport [Array(Integer, Integer), nil] the width and height of the
    #   on-screen viewport
    def viewport=(viewport)
      if viewport
        if viewport.is_a?(Array)
          @viewport = [viewport[0].to_i, viewport[1].to_i]
        elsif viewport.is_a?(Hash)
          @viewport = [viewport[:width], viewport[:height]]
        end
      else
        @viewport = [width, height]
      end
      if @viewport.nil? || @viewport.include?(nil)
        raise ::Plotrb::InvalidInputError
      end
    rescue NoMethodError
      raise ::Plotrb::InvalidInputError
    end

    # @param padding [Integer, Hash] the internal padding from the visualization
    #   edge to the data rectangle
    def padding=(padding)
      @padding = {}
      [:top, :left, :right, :bottom].each do |pos|
        if padding.respond_to?(:to_i)
          @padding[pos] = padding.to_i
        elsif padding.respond_to?(:[])
          @padding[pos] = padding[pos]
        end
        raise ::Plotrb::InvalidInputError if @padding[pos].nil?
      end
    end

    # @param data [Array<Data>] the data for visualization
    def data=(data)
      if array_of_Data?(data)
        @data = data
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # @param scales [Array<Scales>] the scales for visualization
    def scales=(scales)
      if array_of_Scale?(scales)
        @scales = scales
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # @param marks [Array<Marks>] the marks for visualization
    def marks=(marks)
      if array_of_Mark?(marks)
        @marks = marks
      else
        raise ::Plotrb::InvalidInputError
      end
    end

  end


end