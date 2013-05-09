require 'spec_helper'

describe Sleek::Event do
  describe ".create_with_namespace" do
    it "creates event record" do
      expect { Sleek::Event.create_with_namespace(:default, "signups", { name: 'John Doe', email: 'john@doe.com' }) }.to change { Sleek::Event.count }.by(1)
    end

    it "sets namespace and bucket" do
      evt = Sleek::Event.create_with_namespace(:default, "signups", {})
      expect(evt.namespace).to eq :default
      expect(evt.bucket).to eq "signups"
    end

    it "sets the data" do
      data = { name: 'John Doe', email: 'j@d.com' }
      evt = Sleek::Event.create_with_namespace(:ns, "buc", data)
      expect(evt.data).to eq data
    end
  end
end
