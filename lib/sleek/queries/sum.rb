module Sleek
  module Queries
    # Internal: Sum query.
    #
    # Finds the average value for a given property.
    #
    # target_property - the String name of target property on event.
    #
    # Examples
    #
    #   sleek.queries.sum(:purchases, target_property: "total")
    #   # => 2_072_70
    class Sum < Query
      include Targetable

      def perform(events)
        events.sum target_property
      end
    end
  end
end
