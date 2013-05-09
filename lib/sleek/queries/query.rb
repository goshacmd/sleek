module Sleek
  module Queries
    class Query
      attr_reader :namespace, :bucket, :options

      # Internal: Initialize the query.
      #
      # namespace - the Symbol namespace name.
      # bucket    - the String bucket name.
      # options   - the optional Hash of options.
      #
      # Raises ArgumentError if passed options are invalid.
      def initialize(namespace, bucket, options = {})
        @namespace = namespace
        @bucket = bucket
        @options = options

        raise ArgumentError, "options are invalid" unless valid_options?
      end

      # Internal: Get Mongoid::Criteria for events to perform the query.
      def events
        evts = Event.where(namespace: namespace, bucket: bucket)
        evts = evts.between("s.t" => time_range) if time_range
        evts
      end

      # Internal: Get timeframe for the query.
      #
      # Returns nil if no timeframe was passed to initializer.
      def timeframe
        Sleek::Timeframe.new(options[:timeframe]) if options[:timeframe].present?
      end

      # Internal: Get timeframe range.
      def time_range
        timeframe.try(:to_time_range)
      end

      # Internal: Run the query.
      def run
        perform(events)
      end

      # Internal: Perform the query on a set of events.
      def perform(events)
        raise NotImplementedError
      end

      # Internal: Validate the options.
      def valid_options?
        options.is_a?(Hash)
      end
    end
  end
end
