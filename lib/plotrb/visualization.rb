module Plotrb

  class Visualization

    def initialize(args={})
      @name     = args[:name]
      @width    = args[:width] || 500
      @height   = args[:height] || 500
      @viewport = args[:viewport] || [@width, @height]
      @padding  = args[:padding] || 5
    end

    def name
      @name
    end

    def name=(name)
      @name = name.to_s
      if @name.nil? || @name.empty?
        raise ::Plotrb::InvalidInputError
      end
    end

    def width
      @width
    end

    def width=(width)
      if width.respond_to?(:to_i)
        @width = width.to_i
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    def height
      @height
    end

    def height=(height)
      if height.respond_to?(:to_i)
        @height = height.to_i
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    def viewport
      @viewport
    end

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

    def padding
      @padding
    end

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

  end


end