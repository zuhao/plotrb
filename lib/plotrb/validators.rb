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
            array_of_Numeric?(rotate.values[0])
      end
    end

    def array_of_type?(type, arr, size=nil)
      arr.is_a?(Array) && arr.all? { |a| a.is_a?(type)} &&
          (size.nil? || arr.size == size)
    end

    def method_missing(method, *args, &block)
      if method.to_s =~ /^array_of_(.+)\?$/
        if %w(Visualization Transform Data Scale
              Mark Axis ValueRef).include?($1)
          klass = "::Plotrb::#{$1}"
        else
          klass = $1
        end
        array_of_type?(Object.const_get(klass), *args, &block)
      else
        super
      end
    end

  end

end