module Plotrb

  # Data transform performs operations on a data set prior to
  #   visualization.
  # See {https://github.com/trifacta/vega/wiki/Data-Transforms}
  class Transform

    include ::Plotrb::Base

    # all available types of transforms defined by Vega
    TYPES = %i(array copy filter flatten formula sort stats unique zip force geo
               geopath link pie stack treemap wordcloud)

    # @!attributes type
    #   @return [Symbol] the transform type
    add_attributes :type

    def initialize(type, &block)
      if TYPES.include?(type)
        @type = type
        self.send(@type)
        self.instance_eval(&block) if block_given?
      else
        raise ArgumentError
      end
    end

    def type(*args, &block)
      case args.size
        when 0
          @type
        when 1
          initialize(args[0], &block)
          self
        else
          raise ArgumentError
      end
    end

  private

    # Data Manipulation Transforms

    def array
      # @!attributes fields
      #   @return [Array<String>] array of field references to copy
      add_attributes(:fields)
    end

    def copy
      # @!attributes from
      #   @return [String] the name of the object to copy values from
      # @!attributes fields
      #   @return [Array<String>] the fields to copy
      # @!attributes as
      #   @return [Array<String>] the field names to copy the values to
      add_attributes(:from, :fields, :as)
    end


    def facet
      # @!attributes keys
      #   @return [Array<String>] the fields to use as keys
      # @!attributes sort
      #   @return [String, Array<String>] sort criteria
      add_attributes(:keys, :sort)
    end


    def filter
      # @!attributes test
      #   @return [String] the expression for the filter predicate, which
      #     includes the variable `d`, corresponding to the current data object
      add_attributes(:test)
    end

    # no parameter needed
    def flatten; end


    def formula
      # @!attributes field
      #   @return [String] the property name in which to store the value
      # @!attributes
      #   @return expr [String] the expression for the formula
      add_attributes(:field, :expr)
    end


    def sort
      # @!attributes by
      #   @return [String, Array<String>] a list of fields to use as sort
      #     criteria
      add_attributes(:by)
    end


    def stats
      # @!attributes value
      #   @return [String] the field for which to computer the statistics
      # @!attributes median
      #   @return [Boolean] whether median will be computed
      add_attributes(:value, :median)
    end


    def unique
      # @!attributes field
      #   @return [String] the data field for which to compute unique value
      # @!attributes as
      #   @return [String] the field name to store the unique values
      add_attributes(:field, :as)
    end


    def zip
      # @!attributes with
      #   @return [String] the name of the secondary data set to zip with the
      #     primary data set
      # @!attributes as
      #   @return [String] the name of the field to store the secondary data set
      #     values
      # @!attributes key
      #   @return [String] the field in the primary data set to match against
      #     the secondary data set
      # @!attributes with_key
      #   @return [String] the field in the secondary data set to match
      #     against the primary data set
      # @!attributes default
      #   @return [] a default value to use if no matching key value is found
      add_attributes(:with, :as, :key, :with_key, :default)
    end

    # Visual Encoding Transforms


    def force
      # @!attributes links
      #   @return [String] the name of the link (edge) data set, must have
      #     `source` and `target` attributes
      # @!attributes size
      #   @return [Array(Integer, Integer)] the dimensions of the layout
      # @!attributes iterations
      #   @return [Integer] the number of iterations to run
      # @!attributes charge
      #   @return [Numeric, String] the strength of the charge each node exerts
      # @!attributes link_distance
      #   @return [Integer, String] the length of edges
      # @!attributes link_strength
      #   @return [Numeric, String] the tension of edges
      # @!attributes friction
      #   @return [Numeric] the strength of the friction force used to
      #     stabilize the layout
      # @!attributes theta
      #   @return [Numeric] the theta parameter for the Barnes-Hut algorithm
      #     used to compute charge forces between nodes
      # @!attributes gravity
      #   @return [Numeric] the strength of the pseudo-gravity force that pulls
      #     nodes towards the center of the layout area
      # @!attributes alpha
      #   @return [Numeric] a "temperature" parameter that determines how much
      #     node positions are adjusted at each step
      add_attributes(:links, :size, :iterations, :charge, :link_distance,
                     :link_strength, :friction, :theta, :gravity, :alpha)
    end


    def geo
      # @!attributes projection
      #   @return [String] the type of cartographic projection to use
      # @!attributes lon
      #   @return [String] the input longitude values
      # @!attributes lat
      #   @return [String] the input latitude values
      # @!attributes center
      #   @return [Array(Integer, Integer)] the center of the projection
      # @!attributes translate
      #   @return [Array(Integer, Integer)] the translation of the projection
      # @!attributes scale
      #   @return [Numeric] the scale of the projection
      # @!attributes rotate
      #   @return [Numeric] the rotation of the projection
      # @!attributes precision
      #   @return [Numeric] the desired precision of the projection
      # @!attributes clip_angle
      #   @return [Numeric] the clip angle of the projection
      add_attributes(:projection, :lon, :lat, :center, :translate, :scale,
                     :rotate, :precision, :clip_angle)
    end


    def geopath
      # @!attributes field
      #   @return [String] the data field containing the GeoJSON feature data
      # @!attributes (see #geo)
      add_attributes(:field, :projection, :center, :translate, :scale, :rotate,
                     :precision, :clip_angle)
    end


    def link
      # @!attributes source
      #   @return [String] the data field that references the source node for
      #     this link
      # @!attributes target
      #   @return [String] the data field that references the target node for
      #     this link
      # @!attributes shape
      #   @return [Symbol] the path shape to use
      # @!attributes tension
      #   @return [Numeric] the tension in the range [0,1] for the "tightness"
      #     of 'curve'-shaped links
      add_attributes(:source, :target, :shape, :tension)
    end


    def pie
      # @!attributes sort
      #   @return [Boolean] whether to sort the data prior to computing angles
      # @!attributes value
      #   @return [String] the data values to encode as angular spans
      add_attributes(:sort, :value)
    end


    def stack
      # @!attributes point
      #   @return [String] the data field determining the points at which to
      #     stack
      # @!attributes height
      #   @return [String] the data field determining the height of a stack
      # @!attributes offset
      #   @return [Symbol] the baseline offset style
      # @!attributes order
      #   @return [Symbol] the sort order for stack layers
      add_attributes(:point, :height, :offset, :order)
    end


    def treemap
      # @!attributes padding
      #   @return [Integer, Array(Integer, Integer, Integer, Integer)] the
      #     padding to provide around the internal nodes in the treemap
      # @!attributes ratio
      #   @return [Numeric] the target aspect ratio for the layout to optimize
      # @!attributes round
      #   @return [Boolean] whether cell dimensions will be rounded to integer
      #     pixels
      # @!attributes size
      #   @return [Array(Integer, Integer)] the dimensions of the layout
      # @!attributes sticky
      #   @return [Boolean] whether repeated runs of the treemap will use cached
      #     partition boundaries
      # @!attributes value
      #   @return [String] the values to use to determine the area of each
      #     leaf-level treemap cell
      add_attributes(:padding, :ratio, :round, :size, :sticky, :value)
    end


    def wordcloud
      # @!attributes font
      #   @return [String] the font face to use within the word cloud
      # @!attributes font_size
      #   @return [String] the font size for a word
      # @!attributes font_style
      #   @return [String] the font style to use
      # @!attributes font_weight
      #   @return [String] the font weight to use
      # @!attributes padding
      #   @return [Integer, Array(Integer, Integer, Integer, Integer)] the
      #     padding to provide around text in the word cloud
      # @!attributes rotate
      #   @return [String, Hash] the rotation angle for a word
      # @!attributes size
      #   @return [Array(Integer, Integer)] the dimensions of the layout
      # @!attributes text
      #   @return [String] the data field containing the text to visualize
      add_attributes(:font, :fontSize, :fontStyle, :fontWeight, :padding,
                     :rotate, :size, :text)
    end

  end

end
