require 'spec_helper'

describe Sleek::Base do
  subject(:sleek) { Sleek::Base.new(:default) }

  describe "#initialize" do
    it "sets the namespace" do
      sleek = Sleek::Base.new(:my_namespace)
      expect(sleek.namespace).to eq :my_namespace
    end
  end

  describe "#record" do
    it "creates an event record" do
      data = { name: 'John Doe', email: 'j@d.com' }

      Sleek::Event.should_receive(:create_with_namespace).with(:default, "signups", data)

      sleek.record("signups", data)
    end
  end

  describe "#queries" do
    it "returns QueryCollection for current namespace" do
      Sleek::QueryCollection.should_receive(:new).with(:default).and_call_original
      qc = sleek.queries
      expect(qc.namespace).to eq :default
    end
  end
end