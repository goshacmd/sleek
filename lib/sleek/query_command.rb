module Sleek
  # A query command. It's primarily responsible for breaking a
  # timeframe into intervals (if applicable), running the query on each
  # sub-timeframe, and wrapping up a result.
  class QueryCommand
    attr_reader :klass, :namespace, :bucket, :options

    # Initialize a new +QueryCommand+.
    #
    # @param klass [Queries::Query]
    # @param namespace [Namespace]
    # @param bucket [String] bucket name
    # @param options [Hash] options. Everything but +:timeframe+ and +:interval+
    # is passed on to the query class
    #
    # @option options [String, Symbol, Range, Array] :timeframe timeframe description
    # @option options [String] :timezone TZ identifier
    # @option options [Symbol] :interval interval description.
    # Optional. If passed, requires that +:timeframe+ is passed as well
    #
    # @see Interval#initialize
    # @see Timeframe.parse
    #
    # @raise ArgumentError if +:interval+ is passed but +:timeframe+ is not
    def initialize(klass, namespace, bucket, options = {})
      @klass = klass
      @namespace = namespace
      @bucket = bucket
      @timeframe = options.delete(:timeframe)
      @timezone = options.delete(:timezone)
      @interval = options.delete(:interval)
      @options = options

      if @interval.present? && @timeframe.blank?
        raise ArgumentError, 'interval requires timeframe'
      end
    end

    # Check if options include interval.
    def series?
      @interval.present?
    end

    # Parse a time range from the timeframe description.
    # description.
    #
    # @return [Timeframe]
    def timeframe
      Sleek::Timeframe.to_range(@timeframe, @timezone) if @timeframe
    end

    # Split timeframe into sub-timeframes of interval.
    #
    # @return [Array<Range<Time>>]
    def series
      Sleek::Interval.new(@interval, timeframe).timeframes
    end

    # Instantiate a query object.
    #
    # @param timeframe [String, Symbol, Range, Array] timeframe description
    #
    # @see Timeframe.parse
    def new_query(timeframe)
      klass.new(namespace, bucket, options.merge(timeframe: timeframe))
    end

    # Run the query on each timeframe.
    #
    # @return [Array<Hash>]
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
