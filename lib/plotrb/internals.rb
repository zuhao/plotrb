module Plotrb

  # Some internal methods for mixin
  module Internals

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      # override attr_accessor to keep track of attributes
      def attr_accessor(*vars)
        @attributes ||= []
        @attributes.concat(vars)
        super
      end

      def attributes
        @attributes
      end

      def vega_spec?
        true
      end

    end

    # @return [Array<Symbol>] attributes of the particular instance combined
    #   with attributes of the class
    def attributes
      singleton_attr = self.singleton_class.attributes || []
      class_attr = self.class.attributes || []
      singleton_attr.concat(class_attr)
    end

    # add and set new attributes and values to the instance
    # @param args [Hash] attributes in the form of a Hash
    def set_attributes(args)
      args.each do |k, v|
        # use singleton_class as attributes are instance-specific
        self.singleton_class.class_eval { attr_accessor k }
        self.instance_variable_set("@#{k}", v) unless v.nil?
      end
    end

    # add new attributes to the instance
    # @param args [Array<Symbol>] the attributes to add to the instance
    def add_attributes(*args)
      args.each do |k|
        self.singleton_class.class_eval { attr_accessor k }
      end
    end

    # @return [Array<Symbol>] attributes that have values
    def defined_attributes
      attributes.reject { |attr| self.instance_variable_get("@#{attr}").nil? }
    end

    # @return [Boolean] identify if a class includes Internals module, used for
    #   checking the end point of recursion
    def vega_spec?
      self.class.vega_spec?
    end

    # @return [Hash] recursively construct a massive hash
    def collect_attributes
      collected = {}
      defined_attributes.each do |attr|
        value = self.instance_variable_get("@#{attr}")
        if value.respond_to?(:vega_spec?) && value.vega_spec?
          collected[attr] = value.collect_attributes
        elsif value.is_a?(Array)
          collected[attr] = [].concat(value.collect{ |v|
            v.respond_to?(:collect_attributes) ? v.collect_attributes : v })
        else
          collected[attr] = value
        end
      end
      collected
    end

  end

end