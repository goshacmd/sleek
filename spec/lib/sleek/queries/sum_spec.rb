require 'spec_helper'

describe Sleek::Queries::Sum do
  subject(:query) { described_class.new(:default, :purchases, target_property: "total") }

  describe "#perform" do
    it "counts the events" do
      events = stub('events')
      events.should_receive(:sum).with("d.total").and_return(2_072_70)
      expect(query.perform(events)).to eq 2_072_70
    end
  end
end
