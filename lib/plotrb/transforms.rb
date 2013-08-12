module Plotrb

  # Data transform performs operations on a data set prior to
  #   visualization.
  # See {https://github.com/trifacta/vega/wiki/Data-Transforms}
  class Transform

    include ::Plotrb::Base

    # @!attributes type
    #   @return [Symbol] the transform type
    add_attributes :type

    def initialize(type, &block)
      @type = type
      self.send(@type)
      self.instance_eval(&block) if block_given?
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
      define_singleton_method :fields do |*args, &block|
        case args.size
          when 0
            @fields
          else
            @fields = [args].flatten
            self.instance_eval(&block) if block
            self
        end
      end
      self.class_eval { alias_method :take, :fields }
    end

    def copy
      # @!attributes from
      #   @return [String] the name of the object to copy values from
      # @!attributes fields
      #   @return [Array<String>] the fields to copy
      # @!attributes as
      #   @return [Array<String>] the field names to copy the values to
      add_attributes(:from, :fields, :as)
      define_singleton_method :from do |*args, &block|
        case args.size
          when 0
            @from
          when 1
            case args[0]
              when String
                @from = args[0]
              when ::Plotrb::Data
                @from = args[0].name
              else
                raise ArgumentError
            end
            self.instance_eval(&block) if block
            self
          else
            raise ArgumentError
        end
      end

      define_singleton_method :fields do |*args, &block|
        case args.size
          when 0
            @fields
          else
            @fields = [args].flatten
            self.instance_eval(&block) if block
            self
        end
      end
      self.class_eval { alias_method :take, :fields }

      define_singleton_method :as do |*args, &block|
        case args.size
          when 0
            @as
          else
            @as = [args].flatten
            self.instance_eval(&block) if block
            self
        end
      end
    end

    def cross
      # @!attributes with
      #   @return [String] the name of the secondary data to cross with
      # @!attributes diagonal
      #   @return [Boolean] whether diagonal of cross-product will be included
      add_attributes(:with, :diagonal)
      define_singleton_method :with do |*args, &block|
        case args.size
          when 0
            @with
          when 1
            case args[0]
              when String
                @with = args[0]
              when ::Plotrb::Data
                @with = args[0].name
              else
                raise ArgumentError
            end
            self.instance_eval(&block) if block
            self
          else
            raise ArgumentError
        end
      end

      define_singleton_method :diagonal do |&block|
        @diagonal = true
        self.instance_eval(&block) if block
        self
      end
      define_singleton_method :diagonal? do
        @diagonal
      end
      self.class_eval { alias_method :include_diagonal, :diagonal }
      self.class_eval { alias_method :include_diagonal?, :diagonal? }
    end

    def facet
      # @!attributes keys
      #   @return [Array<String>] the fields to use as keys
      # @!attributes sort
      #   @return [String, Array<String>] sort criteria
      add_attributes(:keys, :sort)
      define_singleton_method :keys do |*args, &block|
        case args.size
          when 0
            @keys
          else
            @keys = [args].flatten
            self.instance_eval(&block) if block
            self
        end
      end
      self.class_eval { alias_method :group_by, :keys }

      define_singleton_method :sort do |*args, &block|
        case args.size
          when 0
            @sort
          else
            @sort = [args].flatten
            self.instance_eval(&block) if block
            self
        end
      end
    end

    def filter
      # @!attributes test
      #   @return [String] the expression for the filter predicate, which
      #     includes the variable `d`, corresponding to the current data object
      add_attributes(:test)
      define_singleton_method :test do |*args, &block|
        case args.size
          when 0
            @test
          when 1
            # TODO: validate test expression
            @test = args[0]
            self.instance_eval(&block) if block
            self
          else
            raise ArgumentError
        end
      end
    end

    def flatten
      # no parameter needed
    end

    def fold
      # @!attributes fields
      #   @return [Array<String>] the field references indicating the data
      #     properties to fold
      add_attributes(:fields)
      define_singleton_method :fields do |*args, &block|
        case args.size
          when 0
            @fields
          else
            @fields = [args].flatten
            self.instance_eval(&block) if block
            self
        end
      end
      self.class_eval { alias_method :into, :fields }
    end

    def formula
      # @!attributes field
      #   @return [String] the property name in which to store the value
      # @!attributes
      #   @return expr [String] the expression for the formula
      add_attributes(:field, :expr)
      define_singleton_method :field do |*args, &block|
        case args.size
          when 0
            @field
          when 1
            @field = args[0]
            self.instance_eval(&block) if block
            self
          else
            raise ArgumentError
        end
      end
      self.class_eval { alias_method :into, :field }

      define_singleton_method :expr do |*args, &block|
        case args.size
          when 0
            @expr
          when 1
            # TODO: validate expression
            @expr = args[0]
            self.instance_eval(&block) if block
            self
          else
            raise ArgumentError
        end
      end
      self.class_eval { alias_method :apply, :expr }
    end

    def slice
      # @!attributes by
      #   @return [Integer, Array<Integer>, Symbol] the sub-array to copy
      # @!attributes field
      #   @return [String] the data field to copy the max, min or median value
      add_attributes(:by, :field)
      define_singleton_method :by do |*args, &block|
        case args.size
          when 0
            @by
          when 1
            case args[0]
              when Integer, Array
                @by = args[0]
              when :min, :max, :median
                @by = args[0]
              else
                raise ArgumentError
            end
            self.instance_eval(&block) if block
            self
          else
            raise ArgumentError
        end
      end

      define_singleton_method :field do |*args, &block|
        case args.size
          when 0
            @field
          when 1
            @field = args[0]
            self.instance_eval(&block) if block
            self
          else
            raise ArgumentError
        end
      end
    end

    def sort
      # @!attributes by
      #   @return [String, Array<String>] a list of fields to use as sort
      #     criteria
      add_attributes(:by)
      define_singleton_method :by do |*args, &block|
        case args.size
          when 0
            @by
          else
            @by = [args].flatten
            self.instance_eval(&block) if block
            self
        end
      end
    end

    def stats
      # @!attributes value
      #   @return [String] the field for which to computer the statistics
      # @!attributes median
      #   @return [Boolean] whether median will be computed
      # @!attributes assign
      #   @return [Boolean] whether add stat property to each data element
      add_attributes(:value, :median, :assign)
      define_singleton_method :value do |*args, &block|
        case args.size
          when 0
            @value
          when 1
            @value = args[0]
            self.instance_eval(&block) if block
            self
          else
            raise ArgumentError
        end
      end
      self.class_eval { alias_method :from, :value }

      define_singleton_method :median do |&block|
        @median = true
        self.instance_eval(&block) if block
        self
      end
      define_singleton_method :median? do
        @median
      end
      self.class_eval { alias_method :include_median, :median }
      self.class_eval { alias_method :include_median?, :median? }

      define_singleton_method :assign do |&block|
        @assign = true
        self.instance_eval(&block) if block
        self
      end
      define_singleton_method :assign? do
        @assign
      end
      self.class_eval { alias_method :store_stats, :assign }
      self.class_eval { alias_method :store_stats?, :assign? }
    end

    def truncate
      # @!attributes value
      #   @return [String] the field containing values to truncate
      # @!attributes output
      #   @return [String] the field to store the truncated values
      # @!attributes limit
      #   @return [Integer] maximum length of truncated string
      # @!attributes position
      #   @return [Symbol] the position from which to remove text
      # @!attributes ellipsis
      #   @return [String] the ellipsis for truncated text
      # @!attributes wordbreak
      #   @return [Boolean] whether to truncate along word boundaries
      add_attributes(:value, :output, :limit, :position, :ellipsis, :wordbreak)
    end

    def unique
      # @!attributes field
      #   @return [String] the data field for which to compute unique value
      # @!attributes as
      #   @return [String] the field name to store the unique values
      add_attributes(:field, :as)
    end

    def window
      # @!attributes size
      #   @return [Integer] the size of the sliding window
      # @!attributes step
      #   @return [Integer] the step size to advance the window per frame
      add_attributes(:size, :step)
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
