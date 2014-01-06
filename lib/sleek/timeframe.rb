module Sleek
  class Timeframe
    REGEXP = /(this|previous)_((\d+)_)?(minute|hour|day|week|month)s?/

    class << self
      # Transform the object passed to Timeframe initializer
      # into a range of Time objects.
      #
      # @param timeframe [Range<Time>, Array<Time>, String, Symbol] timeframe description
      # @param timezone [String] TZ identifier.
      #
      # @see ActiveSupport::Timezone
      #
      # @example range of previous two days
      #   Timeframe.to_range :this_2_days
      #
      # @example range of previous hour
      #   Timeframe.to_range :previous_hour
      #
      # @example this day's range in US/Pacific
      #   Timeframe.to_range :this_day, timezone: 'US/Pacific'
      #
      # @raise [ArgumentError] if passed object can't be processed
      def to_range(timeframe, timezone = nil)
        case timeframe
        when proc { |tf| tf.is_a?(Range) && tf.time_range? }
          t = timeframe
        when proc { |tf| tf.is_a?(Array) && tf.size == 2 && tf.count { |_tf| _tf.is_a?(Time) } == 2 }
          t = timeframe.first..timeframe.last
        when String, Symbol
          t = parse(timeframe.to_s, timezone)
        else
          raise ArgumentError, "wrong timeframe - #{timeframe}"
        end
      end

      # Process timeframe string to make up a range.
      #
      # @param timeframe [String] matching +(this|previous)_((\d+)_)?(minute|hour|day|week|month)s?+
      # @param timezone [String] TZ identifier
      #
      # @see ActiveSupport::TimeZone
      def parse(timeframe, timezone = nil)
        _, category, _, number, interval = *timeframe.match(REGEXP)

        unless category && interval
          raise ArgumentError, 'special timeframe string is malformed'
        end

        number ||= 1
        number = number.to_i

        range = range_from_interval(interval, number, timezone)
        range = range - 1.send(interval) if category == 'previous'
        range
      end

      # Create a time range from interval type & number of
      # intervals.
      #
      # @param interval [String] interval type name. Valid values are
      # +minute+, +hour+, +day+, +week+, and +month+.
      #
      # @param number [Integer] number of periods
      # @param timezone [String] TZ identifier
      #
      # @return [Range<TimeWithZone>]
      def range_from_interval(interval, number = 1, timezone = nil)
        timezone ||= 'UTC'
        now = ActiveSupport::TimeZone.new(timezone).now

        end_point = now.send("end_of_#{interval}").round
        start_point = end_point - number.send(interval)

        start_point..end_point
      end
    end
  end
end
