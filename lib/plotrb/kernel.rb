module Plotrb

  # Kernel module includes most of the shortcuts used in Plotrb
  module Kernel

    def method_missing(method, *args, &block)
      case method.to_s
        when /^(x|y)_axis$/
          ::Plotrb::Axis.new($1.to_sym, &block)
        when /^(\w+)_scale$/
          ::Plotrb::Scale.new($1.to_sym, &block)
        when /^(\w+)_transform$/
          ::Plotrb::Transform.new($1.to_sym, &block)
        when /^(\w+)_mark$/
          ::Plotrb::Mark.new($1.to_sym, &block)
        when /data/
          ::Plotrb::Data.new()
        else
          super
      end
    end

  end

end
