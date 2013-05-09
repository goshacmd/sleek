require 'spec_helper'

describe Sleek do
  describe ".for_namespace" do
    it "should return namespaced Sleek::Base instance" do
      Sleek::Base.should_receive(:new).with(:test_ns)
      Sleek.for_namespace(:test_ns)
    end
  end
end
