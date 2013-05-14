require 'spec_helper'

describe Sleek::Queries::Average do
  subject(:query) { described_class.new(:default, :purchases, target_property: "total") }

  describe "#perform" do
    it "counts the events" do
      events = stub('events')
      events.should_receive(:avg).with("d.total").and_return(49_35)
      expect(query.perform(events)).to eq 49_35
    end
  end
end
