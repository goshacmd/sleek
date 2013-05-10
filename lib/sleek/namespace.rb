module Sleek
  class Namespace
    attr_reader :name

    # Internal: Initialize Sleek with namespace.
    #
    # namespace - the Symbol namespace name.
    def initialize(name)
      @name = name
    end

    # Public: Record an event.
    #
    # bucket  - the String name of bucket.
    # payload - the Hash of event data.
    def record(bucket, payload)
      Event.create_with_namespace(name, bucket, payload)
    end

    # Public: Get `QueriesCollection` for the namespace.
    def queries
      @queries ||= QueryCollection.new(name)
    end

    # Public: Delete the namespace.
    def delete!
      events.delete_all
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
      evts = Event.where(namespace: name)
      evts = evts.where(bucket: bucket) if bucket.present?
      evts
    end

    def inspect
      "#<Sleek::Namespace #{name}>"
    end
  end
end
