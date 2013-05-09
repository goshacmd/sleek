require 'spec_helper'

describe Sleek::Queries::Targetable do
  let(:query_superclass) do
    Class.new(Struct.new(:options)) do
      def valid_options?; true; end
    end
  end

  let(:query_class) do
    Class.new(query_superclass) do
      include Sleek::Queries::Targetable
    end
  end

  describe "validation" do
    context "when target_property is passed" do
      it "should pass" do
        expect(query_class.new(target_property: :a).valid_options?).to be true
      end
    end

    context "when target_property is not passed" do
      it "should not pass" do
        expect(query_class.new({}).valid_options?).to be false
      end
    end
  end
end
