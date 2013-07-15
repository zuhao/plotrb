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
            v.respond_to?(:collect_attributes) ? v.collect_attributes : v })
        else
          collected[json_attr] = value
        end
      end
      collected
    end

    def classify(name, format=nil)
      name.to_s.split('_').collect(&:capitalize).join
      name[0].downcase + name[1..-1] if format == :json
    end

    # monkey patch Hash class to support reverse_merge
    class ::Hash

      def reverse_merge(other_hash)
        other_hash.merge(self)
      end

      def collect_attributes
        collected = {}
        self.each do |k, v|
          if v.respond_to?(:collect_attributes)
            collected[k] = v.collect_attributes
          else
            collected[k] = v
          end
        end
        collected
      end

    end

  end

end