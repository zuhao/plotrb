module Plotrb

  module Validators

    include ::Plotrb::Internals
    extend self

    def array_of_type?(type, arr, size=nil)
      klass = Object.const_get(type)
      arr.is_a?(Array) && arr.all? { |a| a.is_a?(klass)} &&
          (size.nil? || arr.size == size)
    rescue NameError
      false
    end

    def method_missing(method, *args, &block)
      if method.to_s =~ /^array_of_(.+)\?$/
        type = classify($1)
        if %w(Visualization Transform Data Scale
              Mark Axis ValueRef).include?(type)
          klass = "::Plotrb::#{type}"
        else
          klass = type
        end
        array_of_type?(klass, *args, &block)
      else
        super
      end
    end

  end

end