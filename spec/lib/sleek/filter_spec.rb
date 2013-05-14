require 'spec_helper'

describe Sleek::Filter do
  describe "#initialize" do
    context "when valid operator is passed" do
      it "does not raise an exception" do
        expect { described_class.new(:test, :eq, 1) }.to_not raise_exception ArgumentError
      end
    end

    context "when invalid operator is passed" do
      it "raises an exception" do
        expect { described_class.new(:test, :lol, 1) }.to raise_exception ArgumentError, "unsupported operator - lol"
      end
    end
  end

  describe "#apply" do
    it "appleis the filter to the criteria" do
      filter = described_class.new(:test, :eq, 1)
      criteria = stub('criteria')
      criteria.should_receive(:eq).with("d.test" => 1)
      filter.apply(criteria)
    end
  end
end
