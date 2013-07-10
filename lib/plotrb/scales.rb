module Plotrb

  # Scales are functions that transform a domain of data values to a range of
  #   visual values.
  # See {https://github.com/trifacta/vega/wiki/Scales}
  class Scale

    include ActiveModel::Validations

    attr_accessor :name, :type, :domain, :domain_min, :domain_max, :range,
                  :range_min, :range_max, :reverse, :round, :points, :clamp,
                  :nice, :exponent, :zero, :data, :field

    class DomainValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors.add(attribute, 'invalid domain')
      end
    end

    validates :name, presence: true, length: { minimum: 1 }
    validates :type, allow_nil: true,
              inclusion: { in: %i(linear ordinal time utc log pow sqrt quantile
                                  quantize threshold) }


    # @param domain [Array(Numeric, Numeric), Array, String] the domain of the
    #   scale, representing the set of data values

    # @param domain_min [Numeric, String] the minimum value in the scale domain

    # @param domain_max [Numeric, String] the maximum value in the scale domain

    # @param range [Array(Numeric, Numeric), Array, String] the range of the
    #   scale, representing the set of visual values

    # @param range_min [Numeric, String] the minimum value in the scale range

    # @param range_max [Numeric, String] the maximum value in the scale range

    # @param reverse [Boolean] whether flips the scale range

    # @param round [Boolean] whether rounds numeric output values to integers

    # Ordinal Scale Properties

    # @param points [Boolean] whether distributes the ordinal values over a
    #   quantitative range at uniformly spaced points or bands

    # Time Scale Properties

    # @param clamp [Boolean] whether clamps values that exceed the data domain
    #   to either to minimum or maximum range value

    # @param nice [Symbol, Boolean, nil] scale domain ina more human-friendly value range

    # Quantitative Scale Properties

    # @param exponent [Numeric] the exponent of the scale transformation

    # @param zero [Boolean] whether zero baseline value is included

    # Scale Domains

    # @param data [String] the name of the data set containing domain values

    # @param field [String, Array<String>] reference to the desired data fields

  end

end