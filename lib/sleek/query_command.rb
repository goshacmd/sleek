module Sleek
  # Internal: A query command. It's primarily responsible for breaking a
  # timeframe into intervals (if applicable), running the query on each
  # sub-timeframe, and wrapping up a result.
  class QueryCommand
    attr_reader :klass, :namespace, :bucket, :options

    # Internal: Initialize the query command.
    #
    # klass     - the Sleek::Queries::Query subclass.
    # namespace - the Sleek::Namespace object.
    # bucket    - the String bucket name.
    # options   - the optional Hash of options. Everything but
    #             :timeframe and :interval will be passed on to the
    #             query class.
    #             :timeframe - the optional timeframe description.
    #             :timezone  - the optional TZ identifier.
    #             :interval  - the optional interval description. If
    #                          passed, requires that :timeframe is passed
    #                          as well.
    #
    # Raises ArgumentError if :interval is passed but :timeframe is not.
    def initialize(klass, namespace, bucket, options = {})
      @klass = klass
      @namespace = namespace
      @bucket = bucket
      @timeframe = options.delete(:timeframe)
      @timezone = options.delete(:timezone)
      @interval = options.delete(:interval)
      @options = options

      raise ArgumentError, "interval requires timeframe" if @interval.present? && @timeframe.blank?
    end

    # Internal: Check if options include interval.
    def series?
      @interval.present?
    end

    # Internal: Parse a time range from the timeframe description.
    # description.
    def timeframe
      Sleek::Timeframe.to_range(@timeframe, @timezone) if @timeframe
    end

    # Internal: Split timeframe into sub-timeframes of interval.
    def series
      Sleek::Interval.new(@interval, timeframe).timeframes
    end

    # Internal: Instantiate a query object.
    #
    # timeframe - the time range.
    def new_query(timeframe)
      klass.new(namespace, bucket, options.merge(timeframe: timeframe))
    end

    # Internal: Run the query on each timeframe.
    def run
      if series?
        series.map do |tf|
          { timeframe: tf, value: new_query(tf).run }
        end
      else
        new_query(timeframe).run
      end
    end
  end
end
