module Sleek
  module Queries
    # Sum query.
    #
    # Finds the average value for a given property.
    #
    # @param target_property [String] name of target property on event
    #
    # @example
    #   sleek.queries.sum(:purchases, target_property: "total")
    #   # => 2_072_70
    class Sum < Query
      require_target_property!

      def perform(events)
        events.sum target_property
      end
    end
  end

  QueryCollection.register :sum, Queries::Sum
end
