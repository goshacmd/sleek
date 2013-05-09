require 'spec_helper'

describe Sleek::Queries::Count do
  subject(:query) { Sleek::Queries::Count.new(:default, :purchases) }

  describe "#perform" do
    it "counts the events" do
      events = stub('events')
      events.should_receive(:count).and_return(42)
      expect(query.perform(events)).to eq 42
    end
  end
end
