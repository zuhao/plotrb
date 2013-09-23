module Plotrb

  # Data transform performs operations on a data set prior to
  #   visualization.
  # See {https://github.com/trifacta/vega/wiki/Data-Transforms}
  class Transform

    include ::Plotrb::Base

    # all available types of transforms defined by Vega
    TYPES = %i(array copy cross facet filter flatten fold formula slice sort
               stats truncate unique window zip force geo geopath link pie stack
               treemap wordcloud)

    TYPES.each do |t|
      define_singleton_method(t) do |&block|
        ::Plotrb::Transform.new(t, &block)
      end
    end

    # @!attributes type
    #   @return [Symbol] the transform type
    add_attributes :type

    def initialize(type, &block)
      @type = type
      @extra_fields = [:index, :data]
      self.send(@type)
      self.instance_eval(&block) if block_given?
      ::Plotrb::Kernel.transforms << self
      self
    end

    def type
      @type
    end

    def extra_fields
      @extra_fields
    end

  private

    # Data Manipulation Transforms

    def array
      # @!attributes fields
      #   @return [Array<String>] array of field references to copy
      add_attributes(:fields)
      define_multi_val_attribute(:fields)
      self.singleton_class.class_eval { alias_method :take, :fields }
    end

    def copy
      # @!attributes from
      #   @return [String] the name of the object to copy values from
      # @!attributes fields
      #   @return [Array<String>] the fields to copy
      # @!attributes as
      #   @return [Array<String>] the field names to copy the values to
      add_attributes(:from, :fields, :as)
      define_single_val_attribute(:from)
      define_multi_val_attributes(:fields, :as)
      self.singleton_class.class_eval { alias_method :take, :fields }
    end

    def cross
      # @!attributes with
      #   @return [String] the name of the secondary data to cross with
      # @!attributes diagonal
      #   @return [Boolean] whether diagonal of cross-product will be included
      add_attributes(:with, :diagonal)
      define_single_val_attribute(:with)
      define_boolean_attribute(:diagonal)
      self.singleton_class.class_eval {
        alias_method :include_diagonal, :diagonal
        alias_method :include_diagonal?, :diagonal?
      }
    end

    def facet
      # @!attributes keys
      #   @return [Array<String>] the fields to use as keys
      # @!attributes sort
      #   @return [String, Array<String>] sort criteria
      add_attributes(:keys, :sort)
      define_multi_val_attributes(:keys, :sort)
      self.singleton_class.class_eval { alias_method :group_by, :keys }
      @extra_fields.concat([:key])
    end

    def filter
      # @!attributes test
      #   @return [String] the expression for the filter predicate, which
      #     includes the variable `d`, corresponding to the current data object
      add_attributes(:test)
      define_single_val_attribute(:test)
    end

    def flatten
      # no parameter needed
    end

    def fold
      # @!attributes fields
      #   @return [Array<String>] the field references indicating the data
      #     properties to fold
      add_attributes(:fields)
      define_multi_val_attribute(:fields)
      self.singleton_class.class_eval { alias_method :into, :fields }
      @extra_fields.concat([:key, :value])
    end

    def formula
      # @!attributes field
      #   @return [String] the property name in which to store the value
      # @!attributes
      #   @return expr [String] the expression for the formula
      add_attributes(:field, :expr)
      define_single_val_attributes(:field, :expr)
      self.singleton_class.class_eval {
        alias_method :into, :field
        alias_method :apply, :expr
      }
    end

    def slice
      # @!attributes by
      #   @return [Integer, Array<Integer>, Symbol] the sub-array to copy
      # @!attributes field
      #   @return [String] the data field to copy the max, min or median value
      add_attributes(:by, :field)
      define_single_val_attributes(:by, :field)
    end

    # TODO: allow reverse sort
    def sort
      # @!attributes by
      #   @return [String, Array<String>] a list of fields to use as sort
      #     criteria
      add_attributes(:by)
      define_multi_val_attribute(:by)
    end

    def stats
      # @!attributes value
      #   @return [String] the field for which to computer the statistics
      # @!attributes median
      #   @return [Boolean] whether median will be computed
      # @!attributes assign
      #   @return [Boolean] whether add stat property to each data element
      add_attributes(:value, :median, :assign)
      define_single_val_attribute(:value)
      define_boolean_attributes(:median, :assign)
      self.singleton_class.class_eval {
        alias_method :from, :value
        alias_method :include_median, :median
        alias_method :include_median?, :median?
        alias_method :store_stats, :assign
        alias_method :store_stats?, :assign?
      }
      @extra_fields.concat([:count, :min, :max, :sum, :mean, :variance, :stdev,
                            :median])
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
      define_single_val_attributes(:value, :output, :limit, :position,
                                   :ellipsis)
      define_boolean_attribute(:wordbreak)
      self.singleton_class.class_eval {
        alias_method :from, :value
        alias_method :to, :output
        alias_method :max_length, :limit
      }
      define_singleton_method :method_missing do |method, *args, &block|
        if method.to_s =~ /^in_(front|back|middle)$/
          self.position($1.to_sym, &block)
        else
          super
        end
      end
    end

    def unique
      # @!attributes field
      #   @return [String] the data field for which to compute unique value
      # @!attributes as
      #   @return [String] the field name to store the unique values
      add_attributes(:field, :as)
      define_single_val_attributes(:field, :as)
      self.singleton_class.class_eval {
        alias_method :from, :field
        alias_method :to, :as
      }
    end

    def window
      # @!attributes size
      #   @return [Integer] the size of the sliding window
      # @!attributes step
      #   @return [Integer] the step size to advance the window per frame
      add_attributes(:size, :step)
      define_single_val_attributes(:size, :step)
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
      define_single_val_attributes(:with, :as, :default, :key, :with_key)
      self.singleton_class.class_eval {
        alias_method :match, :key
        alias_method :against, :with_key
      }
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
      attr = [:links, :size, :iterations, :charge, :link_distance,
              :link_strength, :friction, :theta, :gravity, :alpha]
      add_attributes(*attr)
      define_single_val_attributes(*attr)
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
      attr = [:projection, :lon, :lat, :center, :translate, :scale,
              :rotate, :precision, :clip_angle]
      add_attributes(*attr)
      define_single_val_attributes(*attr)
    end

    def geopath
      # @!attributes value
      #   @return [String] the data field containing the GeoJSON feature data
      # @!attributes (see #geo)
      attr = [:value, :projection, :center, :translate, :scale, :rotate,
              :precision, :clip_angle]
      add_attributes(*attr)
      define_single_val_attributes(*attr)
      @value ||= 'data'
      @extra_fields.concat([:path])
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
      attr = [:source, :target, :shape, :tension]
      add_attributes(*attr)
      define_single_val_attributes(*attr)
      @extra_fields.concat([:path])
    end

    def pie
      # @!attributes sort
      #   @return [Boolean] whether to sort the data prior to computing angles
      # @!attributes value
      #   @return [String] the data values to encode as angular spans
      add_attributes(:sort, :value)
      define_boolean_attribute(:sort)
      define_single_val_attribute(:value)
      @extra_fields.concat([:start_angle, :end_angle])
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
      attr = [:point, :height, :offset, :order]
      add_attributes(*attr)
      define_single_val_attributes(*attr)
      @extra_fields.concat([:y, :y2])
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
      define_single_val_attributes(:padding, :ratio, :size, :value)
      define_boolean_attributes(:round, :sticky)
      @extra_fields.concat([:x, :y, :width, :height])
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
      attr = [:font, :font_size, :font_style, :font_weight, :padding,
              :rotate, :size, :text]
      add_attributes(*attr)
      define_single_val_attribute(*attr)
      @extra_fields.concat([:x, :y, :font_size, :font, :angle])
    end

    def attribute_post_processing
      process_array_fields
      process_copy_as
      process_facet_keys
      process_filter_test
      process_fold_fields
      process_slice_field
      process_stats_value
      process_unique_field
      process_truncate_value
      process_zip_key
      process_zip_with_key
      process_zip_as
      process_geo_lon
      process_geo_lat
      process_link_source
      process_link_target
      process_pie_value
      process_stack_order
      process_stack_point
      process_stack_height
      process_treemap_value
      process_wordcloud_text
      process_wordcloud_font_size
    end

    def process_array_fields
      return unless @type == :array && @fields
      @fields.collect! { |f| get_full_field_ref(f) }
    end

    def process_copy_as
      return unless @type == :copy && @as && @fields
      if @as.is_a?(Array) && @as.size != @fields.size
        raise ArgumentError, 'Unmatched number of fields for copy transform'
      end
    end

    def process_cross_with
      return unless @type == :cross && @with
      case @with
        when String
          unless ::Plotrb::Kernel.find_data(@with)
            raise ArgumentError, 'Invalid data for cross transform'
          end
        when ::Plotrb::Data
          @with = @with.name
        else
          raise ArgumentError, 'Invalid data for cross transform'
      end
    end

    def process_facet_keys
      return unless @type == :facet && @keys
      @keys.collect! { |k| get_full_field_ref(k) }
    end

    def process_filter_test
      return unless @type == :filter && @test
      unless @test =~ /d\./
        raise ArgumentError, 'Invalid filter test string, prefix with \'d.\''
      end
    end

    def process_fold_fields
      return unless @type == :fold && @fields
      @fields.collect! { |f| get_full_field_ref(f) }
    end

    def process_slice_field
      return unless @type == :slice && @field
      @field = get_full_field_ref(@field)
    end

    def process_stats_value
      return unless @type == :stats && @value
      @value = get_full_field_ref(@value)
    end

    def process_unique_field
      return unless @type == :unique && @field
      @field = get_full_field_ref(@field)
    end

    def process_truncate_value
      return unless @type == :truncate && @value
      @value = get_full_field_ref(@value)
    end

    def process_zip_key
      return unless @type == :zip && @key
      @key = get_full_field_ref(@key)
    end

    def process_zip_with_key
      return unless @type == :zip && @with_key
      @with_key = get_full_field_ref(@with_key)
    end

    def process_zip_as
      return unless @type == :zip && @as
      @extra_fields.concat([@as.to_sym])
    end

    def process_geo_lon
      return unless @type == :geo && @lon
      @lon = get_full_field_ref(@lon)
    end

    def process_geo_lat
      return unless @type == :geo && @lat
      @lat = get_full_field_ref(@lat)
    end

    def process_link_source
      return unless @type == :link && @source
      @source = get_full_field_ref(@source)
    end

    def process_link_target
      return unless @type == :link && @target
      @target = get_full_field_ref(@target)
    end

    def process_pie_value
      return unless @type == :pie
      if @value
        @value = get_full_field_ref(@value)
      else
        @value = 'data'
      end
    end

    def process_stack_order
      return unless @order
      case @order
        when :default, 'default', :reverse, 'reverse'
        when :inside_out, 'inside-out', 'inside_out'
          @order = 'inside-out'
        else
          raise ArgumentError, 'Unsupported stack order'
      end
    end

    def process_stack_point
      return unless @type == :stack && @point
      @point = get_full_field_ref(@point)
    end

    def process_stack_height
      return unless @type == :stack && @height
      @height = get_full_field_ref(@height)
    end

    def process_treemap_value
      return unless @type == :treemap && @value
      @value = get_full_field_ref(@value)
    end

    def process_wordcloud_text
      return unless @type == :wordcloud && @text
      @text = get_full_field_ref(@text)
    end

    def process_wordcloud_font_size
      return unless @type == :wordcloud && @font_size
      @font_size = get_full_field_ref(@font_size)
    end

    def get_full_field_ref(field)
      case field
        when String
          if field.start_with?('data.') || extra_fields.include?(field.to_sym)
            field
          else
            "data.#{field}"
          end
        when ::Plotrb::Data
          'data'
        else
          raise ArgumentError, 'Invalid data field'
      end
    end

  end

end
