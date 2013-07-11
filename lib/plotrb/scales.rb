module Plotrb

  # Scales are functions that transform a domain of data values to a range of
  #   visual values.
  # See {https://github.com/trifacta/vega/wiki/Scales}
  class Scale

    include ::Plotrb::Internals
    include ActiveModel::Validations

    # @!attributes name
    #   @return [String] the name of the scale
    # @!attributes type
    #   @return [Symbol] the type of the scale
    # @!attributes domain
    #   @return [Array(Numeric, Numeric), Array, String] the domain of the
    #     scale, representing the set of data values
    # @!attributes domain_min
    #   @return [Numeric, String] the minimum value in the scale domain
    # @!attributes domain_max
    #   @return [Numeric, String] the maximum value in the scale domain
    # @!attributes range
    #   @return [Array(Numeric, Numeric), Array, String] the range of the
    #     scale, representing the set of visual values
    # @!attributes range_min
    #   @return [Numeric, String] the minimum value in the scale range
    # @!attributes range_max
    #   @return [Numeric, String] the maximum value in the scale range
    # @!attributes reverse
    #   @return [Boolean] whether flips the scale range
    # @!attributes round
    #   @return [Boolean] whether rounds numeric output values to integers
    # @!attributes points
    #   @return [Boolean] whether distributes the ordinal values over a
    #     quantitative range at uniformly spaced points or bands
    # @!attributes clamp
    #   @return [Boolean] whether clamps values that exceed the data domain
    #     to either to minimum or maximum range value
    # @!attributes nice
    #   @return [Symbol, Boolean, nil] scale domain in a more human-friendly
    #     value range
    # @!attributes exponent
    #   @return [Numeric] the exponent of the scale transformation
    # @!attributes zero
    #   @return [Boolean] whether zero baseline value is included
    # @!attributes data
    #   @return [String] the name of the data set containing domain values
    # @!attributes field
    #   @return [String, Array<String>] reference to the desired data fields
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

  end

end