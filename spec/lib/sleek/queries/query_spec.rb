require 'spec_helper'

describe Sleek::Queries::Query do
  let(:query_class) { Sleek::Queries::Query }
  let(:namespace) { stub('namespace', name: :default) }
  subject(:query) { query_class.new(namespace, :purchases) }

  describe "#initialize" do
    it "sets the namespace and bucket" do
      my_namespace = stub('my_namespace', name: :my_namespace)
      query = Sleek::Queries::Query.new(my_namespace, :purchases)
      expect(query.namespace).to eq my_namespace
      expect(query.bucket).to eq :purchases
    end

    context "when options are valid" do
      before { query_class.any_instance.stub(valid_options?: true) }

      it "does not raise ArgumerError" do
        expect { query_class.new(:d, :p) }.to_not raise_exception ArgumentError
      end
    end

    context "when options are invalid" do
      before { query_class.any_instance.stub(valid_options?: false) }

      it "raises ArgumentError" do
        expect { query_class.new(:d, :p) }.to raise_exception ArgumentError, "options are invalid"
      end
    end
  end

  describe "#events" do
    let(:evts) { stub('events') }

    context "when group_by is specified" do
      before { query.stub(options: { group_by: "group" }) }

      it "creates a group_by criteria from Mongoid::Criteria" do
        namespace.should_receive(:events).and_return(evts)
        Sleek::GroupByCriteria.should_receive(:new).with(evts, "d.group")

        query.events
      end

      it "returns a group_by criteria" do
        namespace.stub(events: evts)

        crit = query.events

        expect(crit.class).to eq Sleek::GroupByCriteria
        expect(crit.criteria).to eq evts
        expect(crit.group_by).to eq "d.group"
      end
    end

    context "when no timeframe is specifies" do
      context "when no filter is specified" do
        it "returns events in current namespace and bucket" do
          namespace.stub(events: evts)
          namespace.should_receive(:events).with(:purchases)
          query.events
        end
      end

      context "when filter is specified" do
        before { query.stub(filter?: true) }

        it "applies filters" do
          final = stub('final_criteria')
          namespace.stub(events: evts)
          query.should_receive(:apply_filters).and_return(final)
          expect(query.events).to eq final
        end
      end
    end

    context "when timeframe is specified" do
      let(:start) { 1.day.ago }
      let(:finish) { Time.now }
      before { query.stub(:timeframe).and_return(start..finish) }

      context "when no filter is specified" do
        it "gets only events between timeframe ends" do
          pre_evts = stub('pre_events')
          namespace.should_receive(:events).with(:purchases).and_return(pre_evts)
          pre_evts.should_receive(:between).with("s.t" => start..finish)
          query.events
        end
      end

      context "when filter is specified" do
        before { query.stub(filter?: true) }

        it "applies filters" do
          pre_evts = stub('pre_events')
          criteria = stub('criteria')
          final = stub('final_criteria')
          namespace.should_receive(:events).with(:purchases).and_return(pre_evts)
          pre_evts.should_receive(:between).and_return(criteria)
          query.should_receive(:apply_filters).with(criteria).and_return(final)
          expect(query.events).to eq final
        end
      end
    end
  end

  describe "#apply_filters" do
    it "applies every filter to criteria" do
      filters = [Sleek::Filter.new(:test, :gt, 1), Sleek::Filter.new(:test, :lt, 100)]
      query.stub(filter?: true, filters: filters)
      criteria = stub('criteria')
      criteria2 = stub('criteria2')
      final = stub('final_criteria')
      criteria.should_receive(:gt).with("d.test" => 1).and_return(criteria2)
      criteria2.should_receive(:lt).with("d.test" => 100).and_return(final)

      expect(query.apply_filters(criteria)).to eq final
    end
  end

  describe "#filters" do
    context "when filters are specified" do
      context "when proper single filter" do
        before { query.stub(options: { filter: [:test, :gt, 1] }) }

        it "returns an one-element array with Filter" do
          expect(query.filters).to eq [Sleek::Filter.new(:test, :gt, 1)]
        end
      end

      context "when proper multiple filters" do
        before { query.stub(options: { filter: [[:test, :gt, 1], [:test, :lt, 100]] }) }

        it "returns multiple-element array with Filters" do
          expect(query.filters).to eq [Sleek::Filter.new(:test, :gt, 1), Sleek::Filter.new(:test, :lt, 100)]
        end
      end

      context "when malformed filter" do
        before { query.stub(options: { filter: :mwahaha }) }

        it "raises an exception" do
          expect { query.filters }.to raise_exception ArgumentError, "wrong filter - mwahaha"
        end
      end
    end
  end

  describe "#valid_options?" do
    context "when options is a hash" do
      before { query.stub(options: {}) }

      it "is true" do
        expect(query.valid_options?).to be_true
      end
    end

    context "when options isn't a hash" do
      before { query.stub(options: 1) }

      it "is false" do
        expect(query.valid_options?).to be_false
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
