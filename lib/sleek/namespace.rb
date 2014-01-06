module Sleek
  class Namespace
    attr_reader :name

    # Initialize a new +Namespace+.
    #
    # @params name [Symbol] namespace name
    def initialize(name)
      @name = name
    end

    # Record an event.
    #
    # @param bucket [String] bucket name
    # @param payload [Hash] event data
    def record(bucket, payload)
      Event.create_with_namespace(name, bucket, payload)
    end

    # Get +QueriesCollection+ for the namespace.
    #
    # @return [QueriesCollection]
    def queries
      @queries ||= QueryCollection.new(self)
    end

    # Delete the namespace.
    def delete!
      events.delete_all
    end

    # Delete event bucket.
    #
    # @param bucket [String] bucket name
    def delete_bucket(bucket)
      events(bucket).delete_all
    end

    # Delete specific property from all events in the bucket.
    #
    # @param bucket [String] bucket name
    # @param property [String] property name
    def delete_property(bucket, property)
      events(bucket).unset("d.#{property}")
    end

    # Get events associated with current namespace and,
    # optionally, specified bucket.
    #
    # @param bucket [String, nil] bucket name
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
