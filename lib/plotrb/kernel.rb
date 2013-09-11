module Plotrb

  # Kernel module includes most of the shortcuts used in Plotrb
  module Kernel

    # a global space keeping track of all Data objects defined
    def self.data
      @data ||= []
    end

    # @return [Data] find Data object by name
    def self.find_data(name)
      @data.find { |d| d.name == name.to_s }
    end

    # @return [Boolean] if a Data object with same name already exists
    def self.duplicate_data?(name)
      @data.select { |d| d.name == name.to_s }.size > 1
    end

    # a global space keeping track of all Axis objects defined
    def self.axes
      @axes ||= []
    end

    # a global space keeping track of all Scale objects defined
    def self.scales
      @scales ||= []
    end

    # @return [Scale] find Scale object by name
    def self.find_scale(name)
      @scales.find { |s| s.name == name.to_s }
    end

    # a global space keeping track of all Mark objects defined
    def self.marks
      @marks ||= []
    end

    # a global space keeping track of all Transform objects defined
    def self.transforms
      @transforms ||= []
    end

    # Initialize ::Plotrb::Visualization object

    def visualization(&block)
      ::Plotrb::Visualization.new(&block)
    end

    # Initialize ::Plotrb::Data objects

    def pdata(&block)
      ::Plotrb::Data.new(&block)
    end

    def method_missing(method, *args, &block)
      case method.to_s
        when /^(\w+)_axis$/
          # Initialize ::Plotrb::Axis objects
          if ::Plotrb::Axis::TYPES.include?($1.to_sym)
            cache_method($1, 'axis')
            self.send(method)
          else
            super
          end
        when /^(\w+)_scale$/
          # Initialize ::Plotrb::Scale objects
          if ::Plotrb::Scale::TYPES.include?($1.to_sym)
            cache_method($1, 'scale')
            self.send(method)
          else
            super
          end
        when /^(\w+)_transform$/
          # Initialize ::Plotrb::Transform objects
          if ::Plotrb::Transform::TYPES.include?($1.to_sym)
            cache_method($1, 'transform')
            self.send(method)
          else
            super
          end
        when /^(\w+)_mark$/
          # Initialize ::Plotrb::Mark objects
          if ::Plotrb::Mark::TYPES.include?($1.to_sym)
            cache_method($1, 'mark')
            self.send(method)
          else
            super
          end
        else
          super
      end
    end

  protected

    def cache_method(type, klass)
      self.class.class_eval {
        define_method("#{type}_#{klass}") do |&block|
          # class names are constants
          # create shortcut methods to initialize Plotrb objects
          ::Kernel::const_get("::Plotrb::#{klass.capitalize}").
              new(type.to_sym, &block)
        end
      }
    end

  end

end
