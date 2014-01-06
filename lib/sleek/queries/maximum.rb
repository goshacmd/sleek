module Sleek
  module Queries
    # Maximum query.
    #
    # Finds the maximum value for a given property.
    #
    # @param target_property [String] name of target property on event
    #
    # @example
    #   sleek.queries.maximum(:purchases, target_property: "total")
    #   # => 199_99
    class Maximum < Query
      require_target_property!

      def perform(events)
        events.max target_property
      end
    end
  end

  QueryCollection.register :maximum, Queries::Maximum, alias: :max
end
