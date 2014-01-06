module Sleek
  module Queries
    # Average query.
    #
    # Finds the average value for a given property.
    #
    # @param target_property [String] name of target property on event
    #
    # @example
    #   sleek.queries.average(:purchases, target_property: "total")
    #   # => 49_35
    class Average < Query
      require_target_property!

      def perform(events)
        events.avg target_property
      end
    end
  end

  QueryCollection.register :average, Queries::Average, alias: :avg
end
