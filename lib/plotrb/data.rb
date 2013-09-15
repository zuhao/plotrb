module Plotrb

  # The basic tabular data model used by Vega.
  # See {https://github.com/trifacta/vega/wiki/Data}
  class Data

    include ::Plotrb::Base

    # @!attributes name
    #   @return [String] the name of the data set
    # @!attributes format
    #   @return [Format] the format of the data file
    # @!attributes values
    #   @return [Hash, Array, String] the actual data set
    # @!attributes source
    #   @return [String, Data] the name of another data set to use as source
    # @!attributes url
    #   @return [String] the url from which to load the data set
    # @!attributes transform
    #   @return [Array<Transform>] an array of transform definitions
    add_attributes :name, :format, :values, :source, :url, :transform

    def initialize(&block)
      define_single_val_attributes(:name, :values, :source, :url)
      define_multi_val_attribute(:transform)
      self.singleton_class.class_eval {
        alias_method :file, :url
      }
      self.instance_eval(&block) if block_given?
      ::Plotrb::Kernel.data << self
      self
    end

    def format(*args, &block)
      case args.size
        when 0
          @format
        when 1
          @format = ::Plotrb::Data::Format.new(args[0].to_sym, &block)
          self
        else
          raise ArgumentError, 'Invalid Data format'
      end
    end

    def extra_fields
      @extra_fields ||= [:data, :index]
      if @transform
        @extra_fields.concat(@transform.collect { |t| t.extra_fields }).
            flatten!.uniq!
      end
      @extra_fields
    end

    def method_missing(method, *args, &block)
      case method.to_s
        # set format of the data
        when /^as_(csv|tsv|json|topojson|treejson)$/
          self.format($1.to_sym, &block)
        else
          super
      end
    end

  private

    def attribute_post_processing
      process_name
      process_values
      process_source
      process_url
      process_transform
    end

    def process_name
      if @name.nil? || @name.strip.empty?
        raise ArgumentError, 'Name missing for Data object'
      end
      if ::Plotrb::Kernel.duplicate_data?(@name)
        raise ArgumentError, 'Duplicate names for Data object'
      end
    end

    def process_values
      return unless @values
      case @values
        when String
          begin
            Yajl::Parser.parse(@values)
          rescue Yajl::ParseError
            raise ArgumentError, 'Invalid JSON values in Data'
          end
        when Array, Hash
          # leave as it is
        else
          raise ArgumentError, 'Unsupported value type in Data'
      end
    end

    def process_source
      return unless @source
      case source
        when String
          unless ::Plotrb::Kernel.find_data(@source)
            raise ArgumentError, 'Source Data not found'
          end
        when ::Plotrb::Data
          @source = @source.name
        else
          raise ArgumentError, 'Unknown Data source'
      end
    end

    def process_url
      return unless @url
      begin
        URI.parse(@url)
      rescue URI::InvalidURIError
        raise ArgumentError, 'Invalid URL for Data'
      end
    end

    def process_transform
      return unless @transform
      if @transform.any? { |t| not t.is_a?(::Plotrb::Transform) }
        raise ArgumentError, 'Invalid Data Transform'
      end
    end

    class Format

      include ::Plotrb::Base

      add_attributes :type

      def initialize(type, &block)
        case type
          when :json
            add_attributes(:parse, :property)
            define_single_val_attributes(:parse, :property)
          when :csv, :tsv
            add_attributes(:parse)
            define_single_val_attribute(:parse)
          when :topojson
            add_attributes(:feature, :mesh)
            define_single_val_attributes(:feature, :mesh)
          when :treejson
            add_attributes(:parse, :children)
            define_single_val_attributes(:parse, :children)
          else
            raise ArgumentError, 'Invalid Data format'
        end
        @type = type
        self.instance_eval(&block) if block_given?
        self
      end

      def date(*field, &block)
        @parse ||= {}
        field.flatten.each { |f| @parse.merge!(f => :date) }
        self.instance_eval(&block) if block_given?
        self
      end
      alias_method :as_date, :date

      def number(*field, &block)
        @parse ||= {}
        field.flatten.each { |f| @parse.merge!(f => :number) }
        self.instance_eval(&block) if block_given?
        self
      end
      alias_method :as_number, :number

      def boolean(*field, &block)
        @parse ||= {}
        field.flatten.each { |f| @parse.merge!(f => :boolean) }
        self.instance_eval(&block) if block_given?
        self
      end
      alias_method :as_boolean, :boolean

    private

      def attribute_post_processing
        process_parse
        process_property
        process_feature
        process_mesh
        process_children
      end

      def process_parse
        return unless @parse
        valid_type = %i(number boolean date)
        unless @parse.is_a?(Hash) && (@parse.values - valid_type).empty?
          raise ArgumentError, 'Invalid parse options for Data format'
        end
      end

      def process_property
        return unless @property
        unless @property.is_a?(String)
          raise ArgumentError, 'Invalid JSON property'
        end
      end

      def process_feature
        return unless @feature
        unless @feature.is_a?(String)
          raise ArgumentError, 'Invalid TopoJSON feature'
        end
      end

      def process_mesh
        return unless @mesh
        unless @mesh.is_a?(String)
          raise ArgumentError, 'Invalid TopoJSON mesh'
        end
      end

      def process_children
        return unless @children
        unless @children.is_a?(String)
          raise ArgumentError, 'Invalid TreeJSON children'
        end
      end

    end

  end

end
