module Sleek
  class Timeframe
    REGEXP = /(this|previous)_((\d+)_)?(minute|hour|day|week|month)s?/

    class << self
      # Internal: Transform the object passed to Timeframe initializer
      # into a range of Time objects.
      #
      # timeframe - either a Range of Time objects, a two-element array
      #             of Time Objects, or a special string.
      #
      # Examples
      #
      #   Timeframe.to_range :this_2_days
      #
      #   Timeframe.to_range :previous_hour
      #
      # Raises ArgumentError if passed object can't be processed.
      def to_range(timeframe)
        case timeframe
        when proc { |tf| tf.is_a?(Range) && tf.time_range? }
          t = timeframe
        when proc { |tf| tf.is_a?(Array) && tf.size == 2 && tf.count { |_tf| _tf.is_a?(Time) } == 2 }
          t = timeframe.first..timeframe.last
        when String, Symbol
          t = parse(timeframe.to_s)
        else
          raise ArgumentError, "wrong timeframe - #{timeframe}"
        end
      end

      # Internal: Process timeframe string to make up a range.
      #
      # timeframe - the String matching
      #             (this|previous)_((\d+)_)?(minute|hour|day|week|month)s?
      def parse(timeframe)
        _, category, _, number, interval = *timeframe.match(REGEXP)

        unless category && interval
          raise ArgumentError, "special timeframe string is malformed"
        end

        number ||= 1
        number = number.to_i

        end_point = Time.now.send("end_of_#{interval}").round
        start_point = end_point - number.send(interval)

        range = start_point..end_point
        range = range - 1.send(interval) if category == 'previous'
        range
      end
    end
  end
end
