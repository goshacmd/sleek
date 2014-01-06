module Sleek
  # Event filter.
  class Filter
    attr_reader :property_name, :operator, :value

    # Initialize a new +Filter+.
    #
    # @param property_name [String] name of target property
    # @param operator [Symbol] operator name
    # @param value [Object] the value used by operator to compare with the
    # value of target property
    def initialize(property_name, operator, value)
      @property_name = "d.#{property_name}"
      @operator = operator.to_sym
      @value = value

      unless [:eq, :ne, :lt, :lte, :gt, :gte, :in].include? @operator
        raise ArgumentError, "unsupported operator - #{operator}"
      end
    end

    # Apply the filter to a criteria.
    #
    # @param criteria [Mongoid::Criteria]
    def apply(criteria)
      criteria.send(operator, property_name => value)
    end

    # Compare the filter with another. Filters are equal when
    # property name, operator name, and value are equal.
    def ==(other)
      other.is_a?(Filter) && property_name == other.property_name &&
        operator == other.operator && value == other.value
    end
  end
end
