module Plotrb

  # Axes provide axis lines, ticks, and labels to convey how a spatial range
  #   represents a data range.
  # See {https://github.com/trifacta/vega/wiki/Axes}
  class Axis

    include ::Plotrb::Base

    # @!attribute type
    #   @return [Symbol] type of the axis, either :x or :y
    # @!attribute scale
    #   @return [String] the name of the scale backing the axis
    # @!attribute orient
    #   @return [Symbol] the orientation of the axis
    # @!attribute format
    #   @return [String] the formatting pattern for axis labels
    # @!attribute ticks
    #   @return [Integer] a desired number of ticks
    # @!attribute values
    #   @return [Array] explicitly set the visible axis tick values
    # @!attribute subdivide
    #   @return [Integer] the number of minor ticks between major ticks
    # @!attribute tick_padding
    #   @return [Integer] the padding between ticks and text labels
    # @!attribute tick_size
    #   @return [Integer] the size of major, minor, and end ticks
    # @!attribute tick_size_major
    #   @return [Integer] the size of major ticks
    # @!attribute tick_size_minor
    #   @return [Integer] the size of minor ticks
    # @!attribute tick_size_end
    #   @return [Integer] the size of end ticks
    # @!attribute offset
    #   @return [Integer] the offset by which to displace the axis from the edge
    #     of the enclosing group or data rectangle
    # @!attribute properties
    #   @return [Hash] optional mark property definitions for custom styling
    # @!attribute title
    #   @return [String] the title for the axis
    # @!attribute tittle_offset
    #   @return [Integer] the offset from the axis at which to place the title
    # @!attribute grid
    #   @return [Boolean] whether gridlines should be created
    attr_accessor :type, :scale, :orient, :format, :ticks, :values, :subdivide,
                  :tick_padding, :tick_size, :tick_size_major, :tick_size_minor,
                  :tick_size_end, :offset, :properties, :title, :title_offset,
                  :grid

    def initialize(args={}, &block)
      args.each do |k, v|
        self.instance_variable_set("@#{k}", v) if self.attributes.include?(k)
      end
      self.instance_eval(&block) if block_given?
      self
    end

    def type(*args, &block)
      case args.size
        when 0
          @type
        when 1
          @type = args[0]
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end

    def scale(*args, &block)
      case args.size
        when 0
          @scale
        when 1
          scale = args[0]
          @scale =
              case scale
                when ::Plotrb::Scale
                  @scale = scale.name
                when String
                  @scale = scale
                else
                  raise ArgumentError
              end
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end
    alias_method :from, :scale

    def orient(*args, &block)
      case args.size
        when 0
          @orient
        when 1
          @orient = args[0].to_sym
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end

    def title(*args, &block)
      case args.size
        when 0
          @title
        when 1
          @title = args[0]
          self.instance_eval(&block) if block_given?
          self
        when 2
          @title, @title_offset = args[0], args[1]
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end

    def title_offset(*args, &block)
      case args.size
        when 0
          @title_offset
        when 1
          @title_offset = args[0]
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end
    alias_method :offset_title_by, :title_offset

    def format(*args, &block)
      case args.size
        when 0
          @format
        when 1
          @format = format
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end

    def ticks(*args, &block)
      case args.size
        when 0
          @ticks
        when 1
          @ticks = args[0].to_i
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end

    def values(*args, &block)
      case args.size
        when 0
          @values
        when 1 # eg. values([1,2,3,4])
          @values = args[0]
          self.instance_eval(&block) if block_given?
          self
        else # eg. values(1,2,3,4)
          @values = args
          self.instance_eval(&block) if block_given?
          self
      end
    end

    def subdivide(*args, &block)
      case args.size
        when 0
          @subdivide
        when 1
          @subdivide = args[0].to_i
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end
    alias_method :subdivide_by, :subdivide

    def tick_padding(*args, &block)
      case args.size
        when 0
          @tick_padding
        when 1
          @tick_padding = args[0].to_i
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end

    def tick_size(*args, &block)
      case args.size
        when 0
          @tick_size
        when 1
          @tick_size = args[0].to_i
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end

    def tick_size_major(*args, &block)
      case args.size
        when 0
          @tick_size_major
        when 1
          @tick_size_major = args[0].to_i
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end
    alias_method :major_tick_size, :tick_size_major

    def tick_size_minor(*args, &block)
      case args.size
        when 0
          @tick_size_minor
        when 1
          @tick_size_minor = args[0].to_i
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end
    alias_method :minor_tick_size, :tick_size_minor

    def tick_size_end(*args, &block)
      case args.size
        when 0
          @tick_size_end
        when 1
          @tick_size_end = args[0].to_i
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end
    alias_method :end_tick_size, :tick_size_end

    def offset(*args, &block)
      case args.size
        when 0
          @offset
        when 1
          @offset = args[0].to_i
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end
    alias_method :offset_by, :offset

    def layer(*args, &block)
      case args.size
        when 0
          @layer
        when 1
          @layer = args[0].to_sym
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end

    def grid(&block)
      @grid = true
      self.instance_eval(&block) if block_given?
      self
    end
    alias_method :show_grid, :grid
    alias_method :with_grid, :grid

    def grid?
      @grid
    end
    alias_method :show_grid?, :grid?
    alias_method :with_grid?, :grid?

    def method_missing(method, *args, &block)
      case method.to_s
        when /^with_(\d+)_ticks$/  # set number of ticks. eg. in_20_ticks
          self.ticks($1.to_i, &block)
        when /^subdivide_by_(\d+)$/ # set subdivide of ticks
          self.subdivide($1.to_i, &block)
        when /^at_(top|bottom|left|right)$/ # set orient of the axis
          self.orient($1.to_sym, &block)
        when /^in_(front|back)$/ # set layer of the axis
          self.layer($1.to_sym, &block)
        else
          super
      end
    end

  end

end