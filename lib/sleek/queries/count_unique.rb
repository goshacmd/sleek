module Sleek
  module Queries
    # Count unique query.
    #
    # Counts how many events have unique value for a given property.
    #
    # @param target_property [String] name of target property on event
    #
    # @example
    #   sleek.queries.count_unique(:purchases, target_property: "customer.email")
    #   # => 4
    class CountUnique < Query
      require_target_property!

      def perform(events)
        events.distinct(target_property).count
      end
    end
  end

  QueryCollection.register :count_unique, Queries::CountUnique
end
