module Sleek
  class Interval
    attr_reader :interval, :timeframe

    # Internal: Initialize an interval.
    #
    # interval_desc - the Symbol description of the interval.
    #                 Possible values: :hourly, :daily, :weekly,
    #                 :monthly.
    # timeframe     - the range of TimeWithZone objects.
    def initialize(interval_desc, timeframe)
      @interval = self.class.interval_value(interval_desc)
      @timeframe = timeframe
    end

    # Internal: Split the timeframe into intervals.
    #
    # Returns an Array of time range objects.
    def timeframes
      tz = timeframe.first.time_zone
      timeframe.to_i_range.each_slice(interval)
        .to_a[0..-2]
        .map { |tf, _| (tf..(tf + interval)).to_time_range(tz) }
    end

    # Internal: Convert interval description to numeric value.
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
