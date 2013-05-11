module Sleek
  module Queries
    class Query
      attr_reader :namespace, :bucket, :options

      # Internal: Initialize the query.
      #
      # namespace - the Sleek::Namespace object.
      # bucket    - the String bucket name.
      # options   - the optional Hash of options.
      #             :timeframe - the optional timeframe description.
      #             :interval  - the optional interval description.
      #
      # Raises ArgumentError if passed options are invalid.
      def initialize(namespace, bucket, options = {})
        @namespace = namespace
        @bucket = bucket
        @options = options

        raise ArgumentError, "options are invalid" unless valid_options?
      end

      # Internal: Get Mongoid::Criteria for events to perform the query.
      #
      # time_range - the optional range of Time objects.
      def events(time_range = time_range)
        evts = namespace.events(bucket)
        evts = evts.between("s.t" => time_range) if time_range
        evts = apply_filters(evts) if filter?
        evts = Sleek::GroupByCriteria.new(evts, "d.#{group_by}") if group_by.present?
        evts
      end

      # Internal: Apply all the filters to the criteria.
      def apply_filters(criteria)
        filters.inject(criteria) { |crit, filter| filter.apply(crit) }
      end

      # Internal: Get filters.
      def filters
        filters = options[:filter]
        
        if filters.is_a?(Array) && filters.size == 3 && filters.none? { |f| f.is_a?(Array) }
          filters = [filters]
        elsif !filters.is_a?(Array) || !filters.all? { |f| f.is_a?(Array) && f.size == 3 }
          raise ArgumentError, "wrong filter - #{filters}"
        end

        filters.map { |f| Sleek::Filter.new(*f) }
      end

      # Internal: Get timeframe for the query.
      #
      # Returns nil if no timeframe was passed to initializer.
      def timeframe
        Sleek::Timeframe.new(options[:timeframe]) if timeframe?
      end

      # Internal: Get timeframe range.
      def time_range
        timeframe.try(:to_time_range)
      end

      def series
        Sleek::Interval.new(options[:interval], timeframe).timeframes if series? && timeframe?
      end

      # Internal: Check if options include filter.
      def filter?
        options[:filter].present?
      end

      # Internal: Check if options include timeframe.
      def timeframe?
        options[:timeframe].present?
      end

      # Internal: Check if options include interval.
      def series?
        options[:interval].present?
      end

      # Internal: Get group_by property.
      def group_by
        options[:group_by]
      end

      # Internal: Run the query.
      def run
        if series?
          series.map do |tf|
            { timeframe: tf, value: perform(events(tf.to_time_range)) }
          end
        else
          perform(events)
        end
      end

      # Internal: Perform the query on a set of events.
      def perform(events)
        raise NotImplementedError
      end

      # Internal: Validate the options.
      def valid_options?
        options.is_a?(Hash) && (filter? ? options[:filter].is_a?(Array) : true) &&
          (series? ? timeframe? && series : true)
      end
    end
  end
end
