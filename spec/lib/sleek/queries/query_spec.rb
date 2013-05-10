require 'spec_helper'

describe Sleek::Queries::Query do
  let(:query_class) { Sleek::Queries::Query }
  subject(:query) { query_class.new(:default, :purchases) }

  describe "#initialize" do
    it "sets the namespace and bucket" do
      query = Sleek::Queries::Query.new(:my_namespace, :purchases)
      expect(query.namespace).to eq :my_namespace
      expect(query.bucket).to eq :purchases
    end

    context "when options are valid" do
      it "does not raise ArgumerError" do
        query_class.any_instance.stub(valid_options?: true)

        expect { query_class.new(:d, :p) }.to_not raise_exception ArgumentError
      end
    end

    context "when options are invalid" do
      it "raises ArgumentError" do
        query_class.any_instance.stub(valid_options?: false)

        expect { query_class.new(:d, :p) }.to raise_exception ArgumentError, "options are invalid"
      end
    end
  end

  describe "#events" do
    context "when no timeframe is specifies" do
      it "returns events in current namespace and bucket" do
        Sleek::Event.should_receive(:where).with(namespace: :default, bucket: :purchases)
        query.events
      end
    end

    context "when timeframe is specified" do
      let(:start) { 1.day.ago }
      let(:finish) { Time.now }
      before { query.stub(:time_range).and_return(start..finish) }

      it "gets only events between timeframe ends" do
        pre_evts = stub('pre_events')
        Sleek::Event.should_receive(:where).with(namespace: :default, bucket: :purchases).and_return(pre_evts)
        pre_evts.should_receive(:between).with("s.t" => start..finish)
        query.events
      end
    end
  end

  describe "#timeframe" do
    context "when timeframe is specified" do
      it "creates new timeframe instance" do
        tf = stub('timeframe')
        query.stub(options: { timeframe: tf })
        Sleek::Timeframe.should_receive(:new).with(tf)
        query.timeframe
      end
    end
  end

  describe "#series" do
    context "when timeframe and interval are specified" do
      it "splits timeframe into intervals of sub-timeframes" do
        tf_desc = stub('timeframe_desc')
        tf = stub('timeframe')
        interval = stub('interval')
        query.stub(options: { timeframe: tf_desc, interval: :hourly }, timeframe: tf)
        Sleek::Interval.should_receive(:new).with(:hourly, tf).and_return(interval)
        interval.should_receive(:timeframes)
        query.series
      end
    end
  end

  describe "#valid_options?" do
    context "when options is a hash" do
      context "when no interval is passed" do
        it "is true" do
          query.stub(options: {})
          expect(query.valid_options?).to be_true
        end
      end

      context "when interval is passed" do
        context "when timeframe is passed" do
          it "is true" do
            query.stub(options: { interval: :hourly, timeframe: Time.now.all_day })
            expect(query.valid_options?).to be_true
          end
        end

        context "when timeframe is not passed" do
          it "is false" do
            query.stub(options: { interval: :hourly })
            expect(query.valid_options?).to be_false
          end
        end
      end
    end

    context "when options isn't a hash" do
      it "is false" do
        query.stub(options: 1)
        expect(query.valid_options?).to be_false
      end
    end
  end

  describe "#run" do
    context "when no series were requested" do
      it "performs query on events" do
        events = stub
        result = stub
        query.should_receive(:perform).with(events).and_return(result)
        query.stub(events: events)
        query.run
      end
    end

    context "when series were requested" do
      let(:series) { (0..23).to_a.map { |i| stub(to_time_range: (i..(i+1))) } }
      before { query.stub(options: { timeframe: 'this_day', interval: :hourly }, series: series) }

      it "performs query on each of sub-timeframes" do
        24.times do |i|
          evts = stub('events')
          query.should_receive(:events).with(i..(i+1)).and_return(evts)
          query.should_receive(:perform).with(evts)
        end

        query.run
      end

      it "returns the array of results" do
        results = []

        24.times do |i|
          evts = stub('events')
          value = stub('value')
          results << { timeframe: series[i], value: value }
          query.should_receive(:events).with(i..(i+1)).and_return(evts)
          query.should_receive(:perform).with(evts).and_return(value)
        end

        expect(query.run).to eq results
      end
    end
  end
end
