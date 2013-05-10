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

    # Public: Delete event bucket.
    #
    # bucket - the String bucket name.
    def delete_bucket(bucket)
      events(bucket).delete_all
    end

    # Public: Delete specific property from all events in the bucket.
    #
    # bucket   - the String bucket name.
    # property - the String property name.
    def delete_property(bucket, property)
      events(bucket).unset("d.#{property}")
    end

    # Internal: Get events associated with current namespace and,
    # optionally, specified bucket.
    def events(bucket = nil)
      evts = Event.where(namespace: namespace)
      evts = evts.where(bucket: bucket) if bucket.present?
      evts
    end

    def inspect
      "#<Sleek::Base ns=#{namespace}>"
    end
  end
end
