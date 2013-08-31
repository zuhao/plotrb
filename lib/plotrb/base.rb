module Plotrb

  # Some internal methods for mixin
  module Base

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      # add setter methods to attributes
      def add_attributes(*vars)
        @attributes ||= []
        @attributes.concat(vars)
        vars.each do |var|
          define_method("#{var}=") { |value|
            instance_variable_set("@#{var}", value)
          }
        end
      end

      def attributes
        @attributes
      end

    end

    # @return [Array<Symbol>] attributes of the particular instance combined
    #   with attributes of the class
    def attributes
      singleton_attr = self.singleton_class.attributes || []
      class_attr = self.class.attributes || []
      singleton_attr.concat(class_attr).uniq
    end

    # add and set new attributes and values to the instance
    # @param args [Hash] attributes in the form of a Hash
    def set_attributes(args)
      args.each do |k, v|
        # use singleton_class as attributes are instance-specific
        self.singleton_class.add_attributes(k)
        self.instance_variable_set("@#{k}", v) unless v.nil?
      end
    end

    # add new attributes to the instance
    # @param args [Array<Symbol>] the attributes to add to the instance
    def add_attributes(*args)
      self.singleton_class.add_attributes(*args)
    end

    # @return [Array<Symbol>] attributes that have values
    def defined_attributes
      attributes.reject { |attr| self.instance_variable_get("@#{attr}").nil? }
    end

    # @return [Hash] recursively construct a massive hash
    def collect_attributes
      collected = {}
      defined_attributes.each do |attr|
        value = self.instance_variable_get("@#{attr}")
        # change snake_case attributes to camelCase used in Vega's JSON spec
        json_attr = classify(attr, :json)
        if value.respond_to?(:collect_attributes)
          collected[json_attr] = value.collect_attributes
        elsif value.is_a?(Array)
          collected[json_attr] = [].concat(value.collect{ |v|
            v.respond_to?(:collect_attributes) ? v.collect_attributes : v
          })
        else
          collected[json_attr] = value
        end
      end
      collected
    end

    def define_boolean_attribute(method)
      # when setting boolean values, eg. foo.bar sets bar attribute to true,
      #   foo.bar? returns state of bar attribute
      define_singleton_method(method) do |&block|
        self.instance_variable_set("@#{method}", true)
        self.instance_eval(&block) if block
        self
      end
      define_singleton_method("#{method}?") do
        self.instance_variable_get("@#{method}")
      end
    end

    def define_boolean_attributes(*methods)
      methods.each { |m| define_boolean_attribute(m) }
    end

    def define_single_val_attribute(method, proc=nil)
      # when only single value is allowed, eg. foo.bar(1)
      # proc is passed in to process value before assigning to attributes
      define_singleton_method(method) do |*args, &block|
        case args.size
          when 0
            self.instance_variable_get("@#{method}")
          when 1
            val = proc.is_a?(Proc) ? proc.call(args[0]) : args[0]
            self.instance_variable_set("@#{method}", val)
            self.instance_eval(&block) if block
            self
          else
            raise ArgumentError
        end
      end
    end

    def define_single_val_attributes(*methods)
      methods.each { |m| define_single_val_attribute(m) }
    end

    def define_multi_val_attribute(method, proc=nil)
      # when multiple values are allowed, eg. foo.bar(1,2) or foo.bar([1,2])
      # proc is passed in to process values before assigning to attributes
      define_singleton_method(method) do |*args, &block|
        case args.size
          when 0
            self.instance_variable_get("@#{method}")
          else
            vals = proc.is_a?(Proc) ? proc.call(*args) : [args].flatten
            self.instance_variable_set("@#{method}", vals)
            self.instance_eval(&block) if block
            self
        end
      end
    end

    def define_multi_val_attributes(*methods)
      methods.each { |m| define_multi_val_attribute(m) }
    end

    def classify(name, format=nil)
      klass = name.to_s.split('_').collect(&:capitalize).join
      if format == :json
        klass[0].downcase + klass[1..-1]
      else
        klass
      end
    end

    # monkey patch Hash class to support reverse_merge and collect_attributes
    class ::Hash

      def reverse_merge(other_hash)
        other_hash.merge(self)
      end

      def collect_attributes
        collected = {}
        self.each do |k, v|
          json_attr = classify(k, :json)
          if v.respond_to?(:collect_attributes)
            collected[json_attr] = v.collect_attributes
          else
            collected[json_attr] = v
          end
        end
        collected
      end

      def classify(name, format=nil)
        klass = name.to_s.split('_').collect(&:capitalize).join
        if format == :json
          klass[0].downcase + klass[1..-1]
        else
          klass
        end
      end

    end

  end

end
