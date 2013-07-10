module Plotrb

  # Data transform performs operations on a data set prior to
  #   visualization.
  # See {https://github.com/trifacta/vega/wiki/Data-Transforms}
  class Transform

    include ::Plotrb::Internals
    include ::Plotrb::Validators

    # all available types of transforms defined by Vega
    TYPES = %i(array copy filter flatten formula sort stats unique zip force geo
               geopath link pie stack treemap wordcloud)

    attr_reader :type

    # @param type [Symbol, String] type of the transform
    # @param args [Hash, nil] properties of the transform
    def initialize(type, args={})
      if valid_type?(type)
        @type = type.to_sym
        self.send(@type, args)
      else
        raise ::Plotrb::InvalidInputError
      end
    end

    # Data Manipulation Transforms

    # @param fields [Array<String>] array of field references to copy
    def array(fields:[])
      set_properties(:fields => fields)
    end

    # @param from [String] the name of the object to copy values from
    # @param fields [Array<String>] the fields to copy
    # @param as [Array<String>, nil] the field names to copy the values to
    def copy(from:'', fields:[], as:nil)
      # as must be identical in length to the fields parameter
      if as && as.size != fields.size
        raise ::Plotrb::InvalidInputError
      end
      set_properties(:from => from, :fields => fields, :as => as)
    end

    # @param keys [Array<String>] the fields to use as keys
    # @param sort [String, Array<String>, nil] sort criteria
    def facet(keys:[], sort:nil)
      set_properties(:keys => keys, :sort => sort)
    end

    # @param test [String] the expression for the filter predicate, which
    #   includes the variable `d`, corresponding to the current data object
    #TODO: support javascript Math
    def filter(test:'')
      set_properties(:test => test)
    end

    # no parameter needed
    def flatten

    end

    # @param field [String] the property name in which to store the value
    # @param expr [String] the expression for the formula
    #TODO: see (#filter)
    def formula(field:'', expr:'')
      set_properties(:field => field, :expr => expr)
    end

    # @param by [String, Array<String>] a list of fields to use as sort criteria
    def sort(by:[])
      set_properties(:by => by)
    end

    # @param value [String] the field for which to computer the statistics
    # @param median [Boolean, nil] whether median will be computed
    def stats(value:'', median:true)
      set_properties(:value => value, :median => median)
    end

    # @param field [String] the data field for which to compute unique value
    # @param as [String] the field name to store the unique values
    def unique(field:'', as:'')
      set_properties(:field => field, :as => as)
    end

    # @param with [String] the name of the secondary data set to zip with the
    #   primary data set
    # @param as [String] the name of the field to store the secondary data set
    #   values
    # @param key [String] the field in the primary data set to match against the
    #   the secondary data set
    # @param with_key [String] the field in the secondary data set to match
    #   against the primary data set
    # @param default [] a default value to use if no matching key value is found
    def zip(with:'', as:'', key:'', with_key:'', default:nil)
      set_properties(:with => with, :as => as, :key => key,
                     :withKey => with_key, :default => default)
    end

    # Visual Encoding Transforms

    # @param links [String] the name of the link (edge) data set, must have
    #   `source` and `target` attributes
    # @param size [Array(Integer, Integer), nil] the dimensions of the layout
    # @param iterations [Integer, nil] the number of iterations to run
    # @param charge [Numeric, String, nil] the strength of the charge each node
    #   exerts
    # @param link_distance [Integer, String, nil] the length of edges
    # @param link_strength [Numeric, String, nil] the tension of edges
    # @param friction [Numeric, nil] the strength of the friction force used to
    #   stabilize the layout
    # @param theta [Numeric, nil] the theta parameter for the Barnes-Hut
    #   algorithm used to compute charge forces between nodes
    # @param gravity [Numeric, nil] the strength of the pseudo-gravity force
    #   that pulls nodes towards the center of the layout area
    # @param alpha [Numeric, nil] a "temperature" parameter that determines how
    #   much node positions are adjusted at each step
    def force(links:'', size:nil, iterations:nil, charge:nil, link_distance:nil,
        link_strength:nil, friction:nil, theta:nil, gravity:nil, alpha:nil)
      set_properties(:links => links, :size => size, :iterations => iterations,
                     :charge => charge, :linkDistance => link_distance,
                     :linkStrength => link_strength, :friction => friction,
                     :theta => theta, :gravity => gravity, :alpha => alpha)
    end

    # @param projection [String, nil] the type of cartographic projection to use
    # @param lon [String] the input longitude values
    # @param lat [String] the input latitude values
    # @param center [Array(Integer, Integer), nil] the center of the projection
    # @param translate [Array(Integer, Integer), nil] the translation of the
    #   projection
    # @param scale [Numeric, nil] the scale of the projection
    # @param rotate [Numeric, nil] the rotation of the projection
    # @param precision [Numeric, nil] the desired precision of the projection
    # @param clip_angle [Numeric, nil] the clip angle of the projection
    def geo(projection:nil, lon:'', lat:'', center:nil, translate:nil,
        scale:nil, rotate:nil, precision:nil, clip_angle:nil)
      set_properties(:projection => projection, :lon => lon, :lat => lat,
                     :center => center, :translate => translate,
                     :scale => scale, :rotate => rotate,
                     :precision => precision, :clipAngle => clip_angle)
    end

    # @param field [String] the data field containing the GeoJSON feature data
    # @param (see #geo)
    def geopath(field:'', projection:nil, center:nil, translate:nil, scale:nil,
        rotate:nil, precision:nil, clip_angle:nil)
      set_properties(:field => field, :projection => projection,
                     :center => center, :translate => translate,
                     :scale => scale, :rotate => rotate,
                     :precision => precision, :clipAngle => clip_angle)
    end

    # @param source [String, nil] the data field that references the source
    #   node for this link
    # @param target [String, nil] the data field that references the target
    #   node for this link
    # @param shape [Symbol, nil] the path shape to use
    # @param tension [Numeric, nil] the tension in the range [0,1] for the
    #   "tightness" of `curve`-shaped links
    def link(source:nil, target:nil, shape:nil, tension:nil)
      set_properties(:source => source, :target => target, :shape => shape,
                     :tension => tension)
    end

    # @param sort [Boolean, nil] whether to sort the data prior to computing
    #   angles
    # @param value [String, nil] the data values to encode as angular spans
    def pie(sort:true, value:nil)
      set_properties(:sort => sort, :value => value)
    end

    # @param point [String] the data field determining the points at which to
    #   stack
    # @param height [String] the data field determining the height of a stack
    # @param offset [Symbol, nil] the baseline offset style
    # @param order [Symbol, nil] the sort order for stack layers
    def stack(point:'', height:'', offset:nil, order:nil)
      set_properties(:point => point, :height => height, :offset => offset,
                     :order => order)
    end

    # @param padding [Integer, Array(Integer, Integer, Integer, Integer), nil]
    #   the padding to provide around the internal nodes in the treemap
    # @param ratio [Numeric, nil] the target aspect ratio for the layout to
    #   optimize
    # @param round [Boolean, nil] whether cell dimensions will be rounded to
    #   integer pixels
    # @param size [Array(Integer, Integer), nil] the dimensions of the layout
    # @param sticky [Boolean, nil] whether repeated runs of the treemap will
    #   use cached partition boundaries
    # @param value [String] the values to use to determine the area of each
    #   leaf-level treemap cell
    def treemap(padding:nil, ratio:nil, round:true, size:nil, sticky:true,
        value:'')
      set_properties(:padding => padding, :ratio => ratio, :round => round,
                     :size => size, :sticky => sticky, :value => value)
    end

    # @param font [String] the font face to use within the word cloud
    # @param font_size [String] the font size for a word
    # @param font_style [String, nil] the font style to use
    # @param font_weight [String, nil] the font weight to use
    # @param padding [Integer, Array(Integer, Integer, Integer, Integer), nil]
    #   the padding to provide around text in the word cloud
    # @param rotate [String, Hash, nil] the rotation angle for a word
    # @param size [Array(Integer, Integer), nil] the dimensions of the layout
    # @param text [String] the data field containing the text to visualize
    def wordcloud(font:'', font_size:'', font_style:nil, font_weight:nil,
        padding:nil, rotate:nil, size:nil, text:'')
      set_properties(:font => font, :fontSize => font_size,
                     :fontStyle => font_style, :fontWeight => font_weight,
                     :padding => padding, :rotate => rotate, :size => size,
                     :text => text)
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

  end

end