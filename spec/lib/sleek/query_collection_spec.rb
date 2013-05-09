require 'spec_helper'

describe Sleek::QueryCollection do
  subject(:collection) { Sleek::QueryCollection.new(:default) }

  describe "#initialize" do
    it "sets the namespace" do
      collection = Sleek::QueryCollection.new(:my_namespace)
      expect(collection.namespace).to eq :my_namespace
    end
  end

  describe "query methods" do
    it "creates query class and passes options" do
      Sleek::Queries::Count.should_receive(:new).with(:default, :purchases, { some: :opts }).and_call_original
      collection.count(:purchases, { some: :opts })
    end

    it "runs the query" do
      count = stub('count_query')
      Sleek::Queries::Count.should_receive(:new).and_return(count)
      count.should_receive(:run)

      collection.count(:purchases)
    end
  end
end
