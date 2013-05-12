require 'spec_helper'

describe Sleek::QueryCommand do
  let(:query_class) { double('query_class') }
  let(:namespace) { double('namespace', name: :default) }
  let(:bucket) { :purchases }
  subject(:command) { Sleek::QueryCommand.new(query_class, namespace, bucket) }

  describe "#initialize" do
    context "when no timeframe is provided" do
      context "when interval is not provided" do
        let(:command) { Sleek::QueryCommand.new(query_class, namespace, bucket, { some: :opts }) }

        it "sets class" do
          expect(command.klass).to eq query_class
        end

        it "sets namespace" do
          expect(command.namespace).to eq namespace
        end

        it "sets bucket" do
          expect(command.bucket).to eq bucket
        end

        it "sets options" do
          expect(command.options).to eq some: :opts
        end
      end

      context "when interval is provided" do
        it "raises an exception" do
          expect {
            Sleek::QueryCommand.new(query_class, namespace, bucket, interval: :daily)
          }.to raise_exception ArgumentError, "interval requires timeframe"
        end
      end
    end

    context "when timeframe is provided" do
      context "when interval is not provided" do
        let(:command) do
          Sleek::QueryCommand.new(query_class, namespace, bucket, { some: :opts, timeframe: :this_day })
        end

        it "deletes timeframe from options" do
          expect(command.options).to eq some: :opts
        end
      end

      context "when interval is provided" do
        let(:command) do
          Sleek::QueryCommand.new(query_class, namespace, bucket, { some: :opts, timeframe: :this_day, interval: :hourly })
        end

        it "deletes timeframe and interval from options" do
          expect(command.options).to eq some: :opts
        end
      end
    end
  end

  describe "#timeframe" do
    context "when initialized with timeframe" do
      subject(:command) do
        Sleek::QueryCommand.new(query_class, namespace, bucket, timeframe: :this_day)
      end

      it "returns Sleek::Timeframe" do
        tf = double('timeframe')
        Sleek::Timeframe.stub(:to_range).with(:this_day).and_return(tf)
        expect(command.timeframe).to eq tf
      end
    end
  end

  describe "#series" do
    context "when initialized with timeframe and interval" do
      let(:tf) { double('timeframe') }
      let(:interval) { double('interval', timeframes: []) }

      subject(:command) do
        Sleek::QueryCommand.new(query_class, namespace, bucket, timeframe: :this_day, interval: :hourly)
      end

      before do
        Sleek::Interval.stub(:new).and_return(interval)
        command.stub(:timeframe).and_return(tf)
      end

      it "creates a Sleek::Interval" do
        Sleek::Interval.should_receive(:new).with(:hourly, tf).and_return(double.as_null_object)
        command.series
      end

      it "returns sub-timeframes" do
        expect(command.series).to eq interval.timeframes
      end
    end
  end

  describe "#new_query" do
    it "adds timeframe to options and creates a query instance with them" do
      command.stub(:options).and_return(some: :opts)
      query = double('query')
      query_class.should_receive(:new).with(namespace, bucket, { some: :opts, timeframe: :my_tf }).and_return(query)
      expect(command.new_query(:my_tf)).to eq query
    end
  end

  describe "#run" do
    context "when series do not need to be computed" do
      let(:result) { double('result') }
      let(:query) { mock('query', run: result) }
      let(:tf) { double('timeframe') }
      before { command.stub(series?: false, new_query: query, timeframe: tf) }

      it "creates a query" do
        command.should_receive(:new_query).with(tf)
        command.run
      end

      it "runs the query" do
        query.should_receive(:run)
        command.run
      end

      it "returns query result" do
        expect(command.run).to eq result
      end
    end

    context "when series need to be computes" do
      let(:result1) { double('result1') }
      let(:result2) { double('result2') }
      let(:query1) { double('query1', run: result1) }
      let(:query2) { double('query2', run: result2) }
      let(:tf1) { stub('tf1') }
      let(:tf2) { stub('tf2') }
      let(:series) { [tf1, tf2] }

      before do
        command.stub(series?: true, series: series)
        command.stub(:new_query) { |tf| tf == tf1 ? query1 : query2 }
      end

      it "creates a query for each series item" do
        command.should_receive(:new_query).with(tf1)
        command.should_receive(:new_query).with(tf2)
        command.run
      end

      it "runs the query for each series item" do
        query1.should_receive(:run)
        query2.should_receive(:run)
        command.run
      end

      it "returns combined result" do
        expect(command.run).to eq [
          { timeframe: tf1, value: result1 },
          { timeframe: tf2, value: result2 }
        ]
      end
    end
  end
end
