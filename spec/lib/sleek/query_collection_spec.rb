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
    it "creates query command" do
      Sleek::QueryCommand.should_receive(:new).with(Sleek::Queries::Count, namespace, :purchases, { some: :opts }).and_return(stub.as_null_object)
      collection.count(:purchases, { some: :opts })
    end

    it "runs the query command" do
      query_command = stub('query_command')
      Sleek::QueryCommand.should_receive(:new).and_return(query_command)
      query_command.should_receive(:run)

      collection.count(:purchases)
    end
  end
end
