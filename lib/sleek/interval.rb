module Sleek
  class Interval
    attr_reader :interval, :timeframe

    # Initialize a new +Interval+.
    #
    # @param interval_desc [Symbol] description of the interval.
    #                 Possible values: +:hourly+, +:daily+, +:weekly+,
    #                 or +:monthly+.
    # @param timeframe [Range<TimeWithZone>]
    def initialize(interval_desc, timeframe)
      @interval = self.class.interval_value(interval_desc)
      @timeframe = timeframe
    end

    # Split the timeframe into intervals.
    #
    # @return [Array<Range<Time>>]
    def timeframes
      tz = timeframe.first.time_zone
      timeframe.to_i_range.each_slice(interval)
        .to_a[0..-2]
        .map { |tf, _| (tf..(tf + interval)).to_time_range(tz) }
    end

    # Convert interval description to numeric value.
    #
    # @param desc [Symbol] interval description
    #
    # @raise [ArgumentError] if +desc+ is invalid
    #
    # @return [Integer]
    def self.interval_value(desc)
      case desc
      when :hourly
        1.hour
      when :daily
        1.day
      when :weekly
        1.week
      when :monthly
        1.month
      else
        raise ArgumentError, 'invalid interval description'
      end
    end
  end
end
