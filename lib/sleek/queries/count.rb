module Sleek
  module Queries
    # Internal: Count query.
    #
    # Simply counts events.
    #
    # Examples
    #
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
