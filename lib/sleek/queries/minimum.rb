module Sleek
  module Queries
    # Minimum query.
    #
    # Finds the minimum value for a given property.
    #
    # @param target_property [String] name of target property on event
    #
    # @example
    #   sleek.queries.minimum(:purchases, target_property: "total")
    #   # => 19_99
    class Minimum < Query
      require_target_property!

      def perform(events)
        events.min target_property
      end
    end
  end

  QueryCollection.register :minimum, Queries::Minimum, alias: :min
end
