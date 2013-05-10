module Sleek
  class Filter
    attr_reader :property_name, :operator, :value

    def initialize(property_name, operator, value)
      @property_name = "d.#{property_name}"
      @operator = operator.to_sym
      @value = value

      unless [:eq, :ne, :lt, :lte, :gt, :gte, :in].include? @operator
        raise ArgumentError, "unsupported operator - #{operator}"
      end
    end

    def apply(criteria)
      criteria.send(operator, property_name => value)
    end

    def ==(other)
      other.is_a?(Filter) && property_name == other.property_name &&
        operator == other.operator && value == other.value
    end
  end
end
