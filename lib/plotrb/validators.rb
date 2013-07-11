module Plotrb

  module Validators

    extend self

    def valid_type?(type)
      ::Plotrb::Transform::TYPES.include?(type) ||
          ::Plotrb::Transform::TYPES.include?(type.to_sym)
    end

    # TODO: validate D3 projections
    def valid_projection?(projection)
      projection.is_a?(String)
    end

    def valid_shape?(shape)
      [:line, :curve, :diagonal, :diagonalX, :diagonalY].include?(shape.to_sym)
    end

    def valid_tension?(tension)
      tension.is_a?(Numeric) && tension >=0 && tension <=1
    end

    def valid_offset?(offset)
      [:zero, :silhouette, :wiggle, :expand].include?(offset.to_sym)
    end

    def valid_order?(order)
      [:default, :reverse, :'inside-out'].include?(order.to_sym)
    end

    def valid_wordcloud_rotate?(rotate)
      if rotate.is_a?(String)
        true
      elsif rotate.is_a?(Hash)
        (rotate.keys - [:random, :alternate]).empty? && rotate.size == 1 &&
            array_of_numeric?(rotate.values[0])
      end
    end

    def array_of_type?(type, arr, size=nil)
      klass = Object.const_get(type)
      arr.is_a?(Array) && arr.all? { |a| a.is_a?(klass)} &&
          (size.nil? || arr.size == size)
    rescue NameError
      false
    end

    def method_missing(method, *args, &block)
      if method.to_s =~ /^array_of_(.+)\?$/
        type = classify($1)
        if %w(Visualization Transform Data Scale
              Mark Axis ValueRef).include?(type)
          klass = "::Plotrb::#{type}"
        else
          klass = type
        end
        array_of_type?(klass, *args, &block)
      else
        super
      end
    end

    def classify(name)
      name.to_s.split('_').collect(&:capitalize).join
    end

  end

end