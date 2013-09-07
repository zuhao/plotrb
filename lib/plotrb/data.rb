module Plotrb

  # The basic tabular data model used by Vega.
  # See {https://github.com/trifacta/vega/wiki/Data}
  class Data

    include ::Plotrb::Base

    # @!attributes name
    #   @return [String] the name of the data set
    # @!attributes format
    #   @return [Hash] the format of the data file
    # @!attributes values
    #   @return [Hash] the actual data set
    # @!attributes source
    #   @return [String] the name of another data set to use as source
    # @!attributes url
    #   @return [String] the url from which to load the data set
    # @!attributes transform
    #   @return [Array<Transform>] an array of transform definitions
    add_attributes :name, :format, :values, :source, :url, :transform

    def initialize(&block)
      self.instance_eval(&block) if block_given?
      self
    end

    def name(*args, &block)
      case args.size
        when 0
          @name
        when 1
          @name = args[0].to_s
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end

    def format(*args, &block)
      case args.size
        when 0
          @format
        when 1
          @format = ::Plotrb::Data::Format.new(args[0].to_sym, &block)
          self
        else
          raise ArgumentError
      end
    end

    def values(*args, &block)
      case args.size
        when 0
          @values
        when 1
          @values = parse_values(args[0])
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end

    def source(*args, &block)
      case args.size
        when 0
          @source
        when 1
          @source = parse_source(args[0])
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end

    def url(*args, &block)
      case args.size
        when 0
          @url
        when 1
          @url = parse_url(args[0])
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end
    alias_method :file, :url

    def transform(*args, &block)
      case args.size
        when 0
          @transform
        else
          @transform = parse_transform(args)
          self.instance_eval(&block) if block_given?
          self
      end
    end

    def method_missing(method, *args, &block)
      case method.to_s
        when /^as_(csv|tsv|json|topojson|treejson)$/ # set format of the data
          self.format($1.to_sym, &block)
        else
          super
      end
    end

  private

    def parse_transform(transform)
      case transform
        when Array
          transform.collect { |t| parse_transform(t) }.flatten
        when ::Plotrb::Transform
          transform
        else
          raise ArgumentError
      end
    end

    def parse_source(source)
      case source
        when String
          source
        when ::Plotrb::Data
          source.name
        else
          raise ArgumentError
      end
    end

    def parse_url(url)
      url if URI.parse(url)
    rescue URI::InvalidURIError
      raise ArgumentError
    end

    def parse_values(values)
      case values
        when String
          values if Yajl::Parser.parse(values)
        when Array, Hash
          values
        else
          raise ArgumentError
      end
    rescue Yajl::ParseError
      raise ArgumentError
    end

    class Format

      include ::Plotrb::Base

      add_attributes :format

      def initialize(format, &block)
        case format
          when :json
            add_attributes(:parse, :property)
          when :csv, :tsv
            add_attributes(:parse)
          when :topojson
            add_attributes(:feature, :mesh)
          when :treejson
            add_attributes(:children, :parse)
          else
            raise ArgumentError
        end
        @format = format
        self.instance_eval(&block) if block_given?
        self
      end

      def parse(*args, &block)
        case args.size
          when 0
            @parse
          when 1
            # e.g parse('some_field' => :date, 'some_other_field' => :number)
            valid_type = %i(number boolean date)
            raise NoMethodError unless self.attributes.include?(:parse)
            raise ArgumentError unless args[0].is_a?(Hash) &&
                (args[0].values - valid_type).empty?
            @parse ||= {}
            @parse.merge!(args[0])
            self.instance_eval(&block) if block_given?
            self
          else
            raise ArgumentError
        end
      end

      def date(*field, &block)
        field.flatten.each { |f| parse(f => :date) }
        self.instance_eval(&block) if block_given?
        self
      end
      alias_method :as_date, :date

      def number(*field, &block)
        field.flatten.each { |f| parse(f => :number) }
        self.instance_eval(&block) if block_given?
        self
      end
      alias_method :as_number, :number

      def boolean(*field, &block)
        field.flatten.each { |f| parse(f => :boolean) }
        self.instance_eval(&block) if block_given?
        self
      end
      alias_method :as_boolean, :boolean

      def property(*args, &block)
        raise NoMethodError unless self.attributes.include?(:property)
        case args.size
          when 0
            @property
          when 1
            @property = args[0]
            self.instance_eval(&block) if block_given?
            self
          else
            raise ArgumentError
        end
      end

      def feature(*args, &block)
        raise NoMethodError unless self.attributes.include?(:feature)
        case args.size
          when 0
            @feature
          when 1
            @feature = args[0]
            self.instance_eval(&block) if block_given?
            self
          else
            raise ArgumentError
        end
      end

      def mesh(*args, &block)
        raise NoMethodError unless self.attributes.include?(:mesh)
        case args.size
          when 0
            @mesh
          when 1
            @mesh = args[0]
            self.instance_eval(&block) if block_given?
            self
          else
            raise ArgumentError
        end
      end

      def children(*args, &block)
        raise NoMethodError unless self.attributes.include?(:children)
        case args.size
          when 0
            @children
          when 1
            @children = args[0]
            self.instance_eval(&block) if block_given?
            self
          else
            raise ArgumentError
        end
      end

    end

  end

end
