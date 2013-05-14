module Sleek
  module Queries
    # Public: The query.
    #
    # Queries are performed on a set of events and usually return
    # numeric values. You shouldn't be using Sleek::Queries::Query
    # directly, instead, you should subclass it and define `#perform` on
    # it, which takes an events criteria and does its job.
    #
    # Sleek::Queries::Query would take care of processing options,
    # filtering events, handling series and groups.
    #
    # Examples
    #
    #   class SomeQuery < Query
    #     def perform(events)
    #       ...
    #     end
    #   end
    class Query
      attr_reader :namespace, :bucket, :options, :timeframe

      delegate :require_target_property?, to: 'self.class'

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
        @timeframe = options[:timeframe]

        raise ArgumentError, 'options are invalid' unless valid_options?
      end

      # Internal: Get Mongoid::Criteria for events to perform the query.
      #
      # time_range - the optional range of Time objects.
      def events
        evts = namespace.events(bucket)
        evts = evts.between('s.t' => timeframe) if timeframe?
        evts = apply_filters(evts) if filter?

        if group_by.present?
          evts = Sleek::GroupByCriteria.new(evts, "d.#{group_by}")
        end

        evts
      end

      # Internal: Apply all the filters to the criteria.
      def apply_filters(criteria)
        filters.reduce(criteria) { |crit, filter| filter.apply(crit) }
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

      # Internal: Check if options include filter.
      def filter?
        options[:filter].present?
      end

      # Internal: Check if options include timeframe.
      def timeframe?
        timeframe.present?
      end

      # Internal: Get group_by property.
      def group_by
        options[:group_by]
      end

      # Internal: Get the target property.
      def target_property
        if options[:target_property].present?
          "d.#{options[:target_property]}"
        end
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
        options.is_a?(Hash) &&
          (filter? ? options[:filter].is_a?(Array) : true) &&
          (require_target_property? ? options[:target_property].present? : true)
      end

      class << self
        # Public: Indicate that the query requires target property.
        #
        # Examples
        #
        #   class SomeQuery < Query
        #     require_target_property!
        #
        #     def perform(events)
        #       ...
        #     end
        #   end
        def require_target_property!
          @require_target_property = true
        end

        # Public: Check if the query requires target property.
        def require_target_property?
          !!@require_target_property
        end
      end
    end
  end
end
