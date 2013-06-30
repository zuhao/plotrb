module Plotrb

  # Data transform performs operations on a data set prior to
  #   visualization.
  # See {https://github.com/trifacta/vega/wiki/Data-Transforms}
  class Transform

    # all available types of transforms defined by Vega
    TYPES = [
        :array, :copy, :filter, :flatten, :formula, :sort, :stats, :unique,
        :zip, :force, :geo, :geopath, :link, :pie, :stack, :treemap, :wordcloud
    ]

    # @param type [Symbol, String] type of the transform
    def initialize(type, args={})
      if valid_type?(type) && args.is_a?(Hash)
        @type = type.to_sym
        self.send(@type, args)
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # @return [Symbol] type of the transform
    def type
      @type
    end

    # Data Manipulation Transforms

    # @param args [Hash] properties for array transform
    def array(args)
      valid = args[:fields] && (args.keys - [:fields]).empty?
      valid &&= array_of_String?(args[:fields])
      if valid
        set_properties(args)
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # @param args [Hash] properties for copy transform
    def copy(args)
      valid = args[:from] && args[:fields] &&
          (args.keys - [:from, :fields, :as]).empty?
      valid &&= array_of_String?(args[:fields])
      valid &&= args[:as].nil? || args[:as].size == args[:fields].size
      if valid
        set_properties(args)
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # @param args [Hash] properties for facet transform
    def facet(args)
      valid = args[:keys] && (args.keys - [:keys, :sort]).empty?
      valid &&= array_of_String?(args[:keys])
      valid &&= args[:sort].nil? || args[:sort].is_a?(String) ||
          array_of_String?(args[:sort])
      if valid
        set_properties(args)
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # @param args [Hash] properties for filter transform
    #TODO: support javascript Math
    def filter(args)
      valid = args[:test] && (args.keys - [:test]).empty?
      valid &&= args[:test].is_a?(String)
      if valid
        set_properties(args)
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # @param args [nil] properties for flatten transform
    def flatten(args)
      raise ::Plotrb::InvalidInputError unless args.nil?
    end

    # @param args [Hash] properties for formula transform
    #TODO: see (#filter)
    def formula(args)
      valid = args[:field] && args[:expr] &&
          (args.keys - [:field, :expr]).empty?
      valid &&= args[:field].is_a?(String) && args[:expr].is_a?(String)
      if valid
        set_properties(args)
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # @param args [Hash] properties for sort transform
    def sort(args)
      valid = args[:by] && (args.keys - [:by]).empty?
      valid &&= args[:by].is_a?(String) || array_of_String?(args[:by])
      if valid
        set_properties(args)
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # @param args [Hash] properties for stats transform
    def stats(args)
      valid = args[:value] && (args.keys - [:value, :median]).empty?
      valid &&= args[:value].is_a?(String)
      valid &&= args[:median].nil? || [true, false].include?([:median])
      if valid
        set_properties(args)
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # @param args [Hash] properties for unique transform
    def unique(args)
      valid = args[:field] && args[:as] && (args.keys - [:field, :as]).empty?
      valid &&= args[:field].is_a?(String) && args[:as].is_a?(String)
      if valid
        set_properties(args)
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # @param args [Hash] properties for zip transform
    def zip(args)
      valid = args[:key] && args[:with] && args[:as] && args[:withKey] &&
          (args.keys - [:key, :with, :as, :withKey, :default]).empty?
      valid &&= args[:key].is_a?(String) && args[:with].is_a?(String) &&
          args[:as].is_a?(String) && args[:withKey].is_a?(String)
      if valid
        set_properties(args)
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # Visual Encoding Transforms

    # @param args [Hash] properties for force transform
    def force(args)
      valid = args[:links] && (args.keys - [:links, :size, :iterations, :charge,
                                            :linkDistance, :linkStrength,
                                            :friction, :theta, :gravity,
                                            :alpha]).empty?
      valid &&= args[:links].is_a?(String)
      valid &&= args[:size].nil? || array_of_Numeric?(args[:size], size=2)
      valid &&= args[:iterations].nil? || args[:iterations].is_a?(Integer)
      valid &&= args[:charge].nil? || args[:charge].is_a?(Numeric) ||
          args[:charge].is_a?(String)
      valid &&= args[:linkDistance].nil? ||
          args[:linkDistance].is_a?(Numeric) ||
          args[:linkDistance].is_a?(String)
      valid &&= args[:linkStrength].nil? ||
          args[:linkStrength].is_a?(Numeric) ||
          args[:linkStrength].is_a?(String)
      valid &&= args[:friction].nil? || args[:friction].is_a?(Numeric)
      valid &&= args[:theta].nil? || args[:theta].is_a?(Numeric)
      valid &&= args[:gravity].nil? || args[:gravity].is_a?(Numeric)
      valid &&= args[:alpha].nil? || args[:alpha].is_a?(Numeric)
      if valid
        set_properties(args)
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # @param args [Hash] properties for geo transform
    def geo(args)
      valid = args[:lon] && args[:lat] &&
          (args.keys - [:projection, :lon, :lat, :center, :translate, :scale,
                        :rotate, :precision, :clipAngle]).empty?
      valid &&= args[:lon].is_a?(String) && args[:lat].is_a?(String)
      valid &&= args[:projection].nil? || valid_projection?(args[:projection])
      valid &&= args[:center].nil? || array_of_Numeric?(args[:center], size=2)
      valid &&= args[:translate].nil? ||
          array_of_Numeric?(args[:translate], size=2)
      valid &&= args[:scale].nil? || args[:scale].is_a?(Numeric)
      valid &&= args[:rotate].nil? || args[:rotate].is_a?(Numeric)
      valid &&= args[:precision].nil? || args[:precision].is_a?(Numeric)
      valid &&= args[:clipAngle].nil? || args[:clipAngle].is_a?(Numeric)
      if valid
        set_properties(args)
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # @param args [Hash] properties for geopath transform
    def geopath(args)
      valid = args[:field] && (args.keys - [:projection, :field, :center,
                                            :translate, :scale, :rotate,
                                            :precision, :clipAngle]).empty?
      valid &&= args[:field].is_a?(String)
      valid &&= args[:projection].nil? || valid_projection?(args[:projection])
      valid &&= args[:center].nil? || array_of_Numeric?(args[:center], size=2)
      valid &&= args[:translate].nil? ||
          array_of_Numeric?(args[:translate], size=2)
      valid &&= args[:scale].nil? || args[:scale].is_a?(Numeric)
      valid &&= args[:rotate].nil? || args[:rotate].is_a?(Numeric)
      valid &&= args[:precision].nil? || args[:precision].is_a?(Numeric)
      valid &&= args[:clipAngle].nil? || args[:clipAngle].is_a?(Numeric)
      if valid
        set_properties(args)
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # @param args [Hash] properties for link transform
    def link(args)
      valid = (args.keys - [:source, :target, :shape, :tension]).empty?
      valid &&= args[:shape].nil? || valid_shape?(args[:shape])
      valid &&= args[:source].nil? || args[:source].is_a?(String)
      valid &&= args[:target].nil? || args[:target].is_a?(String)
      valid &&= args[:tension].nil? || valid_tension?(args[:tension])
      if valid
        set_properties(args)
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # @param args [Hash] properties for pie transform
    def pie(args)
      valid = (args.keys - [:sort, :value]).empty?
      valid &&= args[:sort].nil? || [true, false].include?(args[:sort])
      valid &&= args[:value].nil? || args[:value].is_a?(String)
      if valid
        set_properties(args)
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # @param args [Hash] properties for stack transform
    def stack(args)
      valid = args[:point] && args[:height]
          (args.keys - [:point, :height, :offset, :order]).empty?
      valid &&= args[:point].is_a?(String) && args[:height].is_a?(String)
      valid &&= args[:offset].nil? || valid_offset?(args[:offset])
      valid &&= args[:order].nil? || valid_order?(args[:order])
      if valid
        set_properties(args)
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # @param args [Hash] properties for treemap transform
    def treemap(args)
      valid = args[:value] && (args.keys - [:padding, :ration, :round, :size,
                                            :sticky, :value]).empty?
      valid &&= args[:value].is_a?(String)
      valid &&= args[:padding].nil? || args[:padding].is_a?(Numeric) ||
          array_of_Numeric?(args[:padding], size=4)
      valid &&= args[:ratio].nil? || args[:ratio].is_a?(Numeric)
      valid &&= args[:round].nil? || [true, false].include?(args[:round])
      valid &&= args[:size].nil? || array_of_Numeric?(args[:size], size=2)
      valid &&= args[:sticky].nil? || [true, false].include?(args[:sticky])
      if valid
        set_properties(args)
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # @param args [Hash] properties for wordcloud transform
    def wordcloud(args)
      valid = args[:text] && args[:font] && args[:fontSize] &&
          (args.keys - [:font, :fontSize, :fontStyle, :fontWeight, :padding,
                        :rotate, :size, :text]).empty?
      valid &&= args[:text].is_a?(String) && args[:fontSize].is_a?(String) &&
          args[:font].is_a?(String)
      valid &&= args[:fontStyle].nil? || args[:fontStyle].is_a?(String)
      valid &&= args[:fontWeight].nil? || args[:fontWeight].is_a?(String)
      valid &&= args[:padding].nil? || args[:padding].is_a?(Numeric) ||
          array_of_Numeric?(args[:padding], size=4)
      valid &&= args[:size].nil? || array_of_Numeric?(args[:size], size=2)
      valid &&= args[:rotate].nil? || valid_wordcloud_rotate?(args[:rotate])
      if valid
        set_properties(args)
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # override attr_accessor to keep track of properties set as attr_accessors
    def self.attr_accessor(*vars)
      @properties ||= []
      @properties.concat(vars)
      super(*vars)
    end

    # @return [Array<Symbol>] properties of the particular Transform instance
    def properties
      self.singleton_class.instance_variable_get(:@properties)
    end

    # @param args [Hash] properties in the form of a Hash
    def set_properties(args)
      args.each do |k, v|
        # use singleton_class here as the properties are for this particular
        #   instance only
        self.singleton_class.class_eval do
          attr_accessor k
        end
        self.instance_variable_set("@#{k}", v)
      end
    end

  private

    def valid_type?(type)
      TYPES.include?(type) || TYPES.include?(type.to_sym)
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
        array_of_type?(Object.const_get($1), *args, &block)
      else
        super
      end
    end

  end

end