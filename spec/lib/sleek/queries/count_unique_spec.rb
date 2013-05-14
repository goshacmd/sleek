require 'spec_helper'

describe Sleek::Queries::CountUnique do
  subject(:query) { described_class.new(:default, :purchases, target_property: "customer.id") }

  describe "#perform" do
    it "counts the events" do
      events = stub('events')
      distinct_events = stub('distinct_events')
      events.should_receive(:distinct).with("d.customer.id").and_return(distinct_events)
      distinct_events.should_receive(:count).and_return(4)
      expect(query.perform(events)).to eq 4
    end
  end
end
