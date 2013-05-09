module Sleek
  class Timeframe
    # Internal: Initialize timeframe.
    #
    # timeframe - either a range of Time objects, an array of two Time
    #             objects, or a special string.
    #
    # Possible special string format:
    # (this|previous)_((\d+)_)?(minute|hour|day|week|month)s?
    #
    # Examples
    #
    #   Timeframe.new "this_2_days"
    #
    #   Timeframe.new "previous_hour"
    def initialize(timeframe)
      @timeframe = timeframe
    end

    # Public: Get timeframe start.
    def start
      to_time_range.begin
    end

    # Public: Get timeframe end.
    def end
      to_time_range.end
    end

    # Internal: Convert Timeframe instance to a range of Time objects.
    def to_time_range
      @range ||= self.class.to_range(@timeframe)
    end

    class << self
      # Internal: Transform the object passed to Timeframe initializer
      # into a range of Time objects.
      #
      # timeframe - either a Range of Time objects, a two-element array
      #             of Time Objects, or a special string.
      #
      # Raises ArgumentError if passed object can't be processed.
      def to_range(timeframe)
        case timeframe
        when Range
          t = timeframe if timeframe.time_range?
        when Array
          t = timeframe.first..timeframe.last if timeframe.size == 2 && timeframe.count { |tf| tf.is_a?(Time) } == 2
        when String, Symbol
          t = process(timeframe.to_s)
        end

        raise ArgumentError, "wrong timeframe" unless t
        t
      end

      # Internal: Process timeframe string to make up a range.
      #
      # timeframe - the String matching
      #             (this|previous)_((\d+)_)?(minute|hour|day|week|month)s?
      def parse(timeframe)
        regexp = /(this|previous)_((\d+)_)?(minute|hour|day|week|month)s?/
        _, category, _, number, interval = *timeframe.match(regexp)

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
