require 'spec_helper'

describe Sleek::Queries::Maximum do
  subject(:query) { Sleek::Queries::Maximum.new(:default, :purchases, target_property: "total") }

  describe "#perform" do
    it "counts the events" do
      events = stub('events')
      events.should_receive(:max).with("d.total").and_return(199_99)
      expect(query.perform(events)).to eq 199_99
    end
  end
end
