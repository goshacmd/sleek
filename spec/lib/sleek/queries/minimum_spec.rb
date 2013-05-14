require 'spec_helper'

describe Sleek::Queries::Minimum do
  subject(:query) { described_class.new(:default, :purchases, target_property: "total") }

  describe "#perform" do
    it "counts the events" do
      events = stub('events')
      events.should_receive(:min).with("d.total").and_return(19_99)
      expect(query.perform(events)).to eq 19_99
    end
  end
end
