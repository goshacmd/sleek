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

  describe "#run" do
    it "performs query on events" do
      events = stub
      result = stub
      query.should_receive(:perform).with(events).and_return(result)
      query.stub(events: events)
      query.run
    end
  end
end
