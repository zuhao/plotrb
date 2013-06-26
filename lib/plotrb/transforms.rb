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
      valid = args[:fields] && ([:fields] - args.keys).empty?
      valid &&= array_of_strings?(args[:fields])
      if valid
        set_properties(args)
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # @param args [Hash] properties for copy transform
    def copy(args)
      valid = args[:from] && args[:fields] &&
          ([:from, :fields, :as] - args.keys).empty?
      valid &&= array_of_strings?(args[:fields])
      valid &&= args[:as].nil? || args[:as].size == args[:fields].size
      if valid
        set_properties(args)
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # @param args [Hash] properties for facet transform
    def facet(args)
      valid = args[:keys] && ([:keys, :sort] - args.keys).empty?
      valid &&= array_of_strings?(args[:keys])
      valid &&= args[:sort].nil? || args[:sort].is_a?(String) ||
          array_of_strings?(args[:sort])
      if valid
        set_properties(args)
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # @param args [Hash] properties for filter transform
    #TODO: support javascript Math
    def filter(args)
      valid = args[:test] && ([:test] - args.keys).empty?
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
          ([:field, :expr] - args.keys).empty?
      valid &&= args[:field].is_a?(String) && args[:expr].is_a?(String)
      if valid
        set_properties(args)
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # @param args [Hash] properties for sort transform
    def sort(args)
      valid = args[:by] && ([:by] - args.keys).empty?
      valid &&= args[:by].is_a?(String) || array_of_strings?(args[:by])
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

    end

    # @param args [Hash] properties for geo transform
    def geo(args)

    end

    # @param args [Hash] properties for geopath transform
    def geopath(args)

    end

    # @param args [Hash] properties for link transform
    def link(args)

    end

    # @param args [Hash] properties for pie transform
    def pie(args)

    end

    # @param args [Hash] properties for stack transform
    def stack(args)

    end

    # @param args [Hash] properties for treemap transform
    def treemap(args)

    end

    # @param args [Hash] properties for wordcloud transform
    def wordcloud(args)

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

    def array_of_strings?(arr)
      arr.is_a?(Array) && arr.all? { |f| f.is_a?(String) }
    end

  end

end