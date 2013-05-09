module Sleek
  class Base
    attr_reader :namespace

    # Internal: Initialize Sleek with namespace.
    #
    # namespace - the Symbol namespace name.
    def initialize(namespace)
      @namespace = namespace
    end

    # Public: Record an event.
    #
    # bucket  - the String name of bucket.
    # payload - the Hash of event data.
    def record(bucket, payload)
      Event.create_with_namespace(namespace, bucket, payload)
    end

    # Public: Get `QueriesCollection` for the namespace.
    def queries
      @queries ||= QueryCollection.new(namespace)
    end
  end
end
