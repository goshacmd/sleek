module Sleek
  module Queries
    # Internal: Average query.
    #
    # Finds the average value for a given property.
    #
    # target_property - the String name of target property on event.
    #
    # Examples
    #
    #   sleek.queries.average(:purchases, target_property: "total")
    #   # => 49_35
    class Average < Query
      require_target_property!

      def perform(events)
        events.avg target_property
      end
    end
  end
end
