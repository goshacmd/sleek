module Sleek
  module Queries
    # Internal: Minimum query.
    #
    # Finds the minimum value for a given property.
    #
    # target_property - the String name of target property on event.
    #
    # Examples
    #
    #   sleek.queries.minimum(:purchases, target_property: "total")
    #   # => 19_99
    class Minimum < Query
      require_target_property!

      def perform(events)
        events.min target_property
      end
    end
  end

  QueryCollection.register :minimum, Queries::Minimum
end
