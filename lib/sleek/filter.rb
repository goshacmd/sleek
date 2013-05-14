module Sleek
  class Filter
    attr_reader :property_name, :operator, :value

    # Internal: Initialize a filter.
    #
    # property_name - the String name of target property.
    # operator      - the Symbol operator name.
    # value         - the value used by operator to compare with the
    #                 value of target property.
    def initialize(property_name, operator, value)
      @property_name = "d.#{property_name}"
      @operator = operator.to_sym
      @value = value

      unless [:eq, :ne, :lt, :lte, :gt, :gte, :in].include? @operator
        raise ArgumentError, "unsupported operator - #{operator}"
      end
    end

    # Internal: Apply the filter to a criteria.
    #
    # criteria - the Mongoid::Criteria object.
    def apply(criteria)
      criteria.send(operator, property_name => value)
    end

    # Internal: Compare the filter with another. Filters are equal when
    # property name, operator name, and value are equal.
    def ==(other)
      other.is_a?(Filter) && property_name == other.property_name &&
        operator == other.operator && value == other.value
    end
  end
end
