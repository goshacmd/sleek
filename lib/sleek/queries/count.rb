module Sleek
  module Queries
    # Count query.
    #
    # Simply counts events.
    #
    # @example
    #   sleek.queries.count(:purchases)
    #   # => 42
    class Count < Query
      def perform(events)
        events.count
      end
    end
  end

  QueryCollection.register :count, Queries::Count
end
