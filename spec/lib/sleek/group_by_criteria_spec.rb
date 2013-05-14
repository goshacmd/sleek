require 'spec_helper'

describe Sleek::GroupByCriteria do
  let(:collection) { mock('collection', aggregate: []) }
  let(:criteria) { mock('criteria', collection: collection) }
  let(:group_by) { "d.field" }
  let(:db_group) { "$d.field" }
  subject(:crit) { described_class.new(criteria, group_by) }

  describe "#aggregates" do
    it "makes up the pipeline" do
      crit.should_receive(:aggregates_pipeline).with(:some_field, false)

      crit.aggregates(:some_field, false)
    end

    it "aggregates on the collection" do
      pipeline = double('pipeline')
      result_a = double('result_a')
      result = double('result', to_a: result_a)
      crit.stub(:aggregates_pipeline).and_return(pipeline)
      collection.should_receive(:aggregate).with(pipeline).and_return(result)

      expect(crit.aggregates(:some_field, false)).to eq result_a
    end
  end

  describe "#aggregates_prop" do
    it "aggregates on the collection" do
      crit.should_receive(:aggregates).with(:some_field, false).and_return([])
      crit.aggregates_prop(:some_field, "count", false)
    end

    it "maps the result" do
      crit.stub(:aggregates).and_return([{"_id" => :a, "count" => 1}, {"_id" => :b, "count" => 4}])
      expect(crit.aggregates_prop(:some_field, "count", false)).to eq({ a: 1, b: 4 })
    end
  end

  describe "#aggregates_pipeline" do
    let(:new_criteria) { stub('new_criteria') }
    let(:selector) { stub('selector') }

    context "when not aggregating on specific field" do
      let(:pipeline) { crit.aggregates_pipeline }

      before do
        criteria.should_receive(:ne).with(group_by => nil).and_return(new_criteria)
        new_criteria.should_receive(:selector).and_return(selector)
      end

      it "adds group_by_field != nil to criteria and matches the criteria" do
        expect(pipeline.first).to eq "$match" => selector
      end

      it "groups with count" do
        expect(pipeline.last).to eq "$group" => { "_id" => db_group, "count" => { "$sum" => 1 } }
      end

      it "has only two operators" do
        expect(pipeline).to have(2).items
      end
    end

    context "when aggregating on specific field" do
      let(:field) { "d.property" }
      let(:db_field) { "$d.property" }
      let(:new_criteria2) { stub('new_criteria2') }

      before do
        criteria.should_receive(:ne).with(field => nil).and_return(new_criteria)
        new_criteria.should_receive(:ne).with(group_by => nil).and_return(new_criteria2)
        new_criteria2.should_receive(:selector).and_return(selector)
      end

      context "when not including unique counter" do
        let(:pipeline) { crit.aggregates_pipeline(field) }

        it "adds group_by_field != nil and field != nil to criteria and matches the criteria" do
          expect(pipeline.first).to eq "$match" => selector
        end

        it "groups with count, min, max, sum, avg" do
          expect(pipeline.last).to eq "$group" => {
            "_id" => db_group, 
            "count" => { "$sum" => 1 },
            "max" => { "$max" => db_field },
            "min" => { "$min" => db_field },
            "sum" => { "$sum" => db_field },
            "avg" => { "$avg" => db_field }
          }
        end

        it "has 2 operators" do
          expect(pipeline).to have(2).items
        end
      end

      context "when including unique counter" do
        let(:pipeline) { crit.aggregates_pipeline(field, true) }

        it "adds group_by_field != nil and field != nil to criteria and matches the criteria" do
          expect(pipeline.first).to eq "$match" => selector
        end

        it "groups with count, min, max, sum, avg" do
          expect(pipeline[1]).to eq "$group" => {
            "_id" => db_group, 
            "count" => { "$sum" => 1 },
            "max" => { "$max" => db_field },
            "min" => { "$min" => db_field },
            "sum" => { "$sum" => db_field },
            "avg" => { "$avg" => db_field },
            "unique_set" => { "$addToSet" => db_field }
          }
        end

        it "unwinds the set of unique values" do
          expect(pipeline[2]).to eq "$unwind" => "$unique_set"
        end

        it "groups aggregates back and counts unique values" do
          expect(pipeline.last).to eq "$group" => {
            "_id" => "$_id",
            "count_unique" => { "$sum" => 1 },
            "count" => { "$first" => "count" },
            "max" => { "$first" => "max" },
            "min" => { "$first" => "min" },
            "avg" => { "$first" => "avg" }
          }
        end

        it "has 4 operators" do
          expect(pipeline).to have(4).items
        end
      end
    end
  end
end
