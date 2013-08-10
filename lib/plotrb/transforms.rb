module Plotrb

  # Data transform performs operations on a data set prior to
  #   visualization.
  # See {https://github.com/trifacta/vega/wiki/Data-Transforms}
  class Transform

    include ::Plotrb::Base

    # all available types of transforms defined by Vega
    TYPES = %i(array copy filter flatten formula sort stats unique zip force geo
               geopath link pie stack treemap wordcloud)

    # @!attributes type
    #   @return [Symbol] the transform type
    add_attributes :type

    def initialize(type, &block)
      case type
        when :array
          add_attributes(:fields)
        when :copy
          add_attributes(:from, :fields, :as)
        when :facet
          add_attributes(:keys, :sort)
        when :filter
          add_attributes(:test)
        when :flatten
        when :formula
          add_attributes(:field, :expr)
        when :sort
          add_attributes(:field, :expr)
        when :stats
          add_attributes(:value, :median)
        when :unique
          add_attributes(:field, :as)
        when :zip
          add_attributes(:with, :as, :key, :with_key, :default)
        when :force
          add_attributes(:links, :size, :iterations, :charge, :link_distance,
                         :link_strength, :friction, :theta, :gravity, :alpha)
        when :geo
          add_attributes(:projection, :lon, :lat, :center, :translate, :scale,
                         :rotate, :precision, :clip_angle)
        when :geopath
          add_attributes(:field, :projection, :center, :translate, :scale, :rotate,
                         :precision, :clip_angle)
        when :link
          add_attributes(:source, :target, :shape, :tension)
        when :pie
          add_attributes(:sort, :value)
        when :stack
          add_attributes(:point, :height, :offset, :order)
        when :treemap
          add_attributes(:padding, :ratio, :round, :size, :sticky, :value)
        when :wordcloud
          add_attributes(:font, :fontSize, :fontStyle, :fontWeight, :padding,
                         :rotate, :size, :text)
        else
          raise ArgumentError
      end
      @type = type
      self.instance_eval(&block) if block_given?
      self
    end

    def type(*args, &block)
      case args.size
        when 0
          @type
        when 1
          initialize(args[0], &block)
          self
        else
          raise ArgumentError
      end
    end

  end

end