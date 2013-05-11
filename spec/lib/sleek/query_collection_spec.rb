require 'spec_helper'

describe Sleek::QueryCollection do
  let(:namespace) { stub('namespace', name: :default) }
  subject(:collection) { Sleek::QueryCollection.new(namespace) }

  describe "#initialize" do
    it "sets the namespace" do
      my_namespace = stub('my_namespace', name: :my_namespace)
      collection = Sleek::QueryCollection.new(my_namespace)
      expect(collection.namespace).to eq my_namespace
    end
  end

  describe "query methods" do
    it "creates query class and passes options" do
      query = stub('query', run: nil)
      Sleek::Queries::Count.should_receive(:new).with(namespace, :purchases, { some: :opts }).and_return(query)
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
