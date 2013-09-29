module Sleek
  module Queries
    # Internal: Maximum query.
    #
    # Finds the maximum value for a given property.
    #
    # target_property - the String name of target property on event.
    #
    # Examples
    #
    #   sleek.queries.maximum(:purchases, target_property: "total")
    #   # => 199_99
    class Maximum < Query
      require_target_property!

      def perform(events)
        events.max target_property
      end
    end
  end

  QueryCollection.register :maximum, Queries::Maximum
end
