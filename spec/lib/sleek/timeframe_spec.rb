require 'spec_helper'

describe Sleek::Timeframe do
  let(:start_time) { 1.day.ago }
  let(:end_time) { Time.now }
  let(:range) { start_time..end_time }
  subject(:timeframe) { Sleek::Timeframe.new(range) }

  describe "#start" do
    it "returns timeframe start" do
      expect(timeframe.start).to eq start_time
    end
  end

  describe "#end" do
    it "returns timeframe end" do
      expect(timeframe.end).to eq end_time
    end
  end

  describe "#to_time_range" do
    it "transforms passed timeframe to range" do
      Sleek::Timeframe.should_receive(:to_range).with(range)
      timeframe.to_time_range
    end
  end

  describe ".to_range" do
    context "when passed a range" do
      context "when the range is of Time objects" do
        it "returns that range" do
          expect(Sleek::Timeframe.to_range(range)).to eq range
        end
      end

      context "when passed other range" do
        it "raises an exception" do
          expect { Sleek::Timeframe.to_range(1..3) }.to raise_exception ArgumentError
        end
      end
    end

    context "when passed an array" do
      context "when array has two Time elements" do
        it "constructs the range" do
          expect(Sleek::Timeframe.to_range([start_time, end_time])).to eq range
        end
      end

      context "when passed other array" do
        it "raises an exception" do
          expect { Sleek::Timeframe.to_range([1, 2]) }.to raise_exception ArgumentError
          expect { Sleek::Timeframe.to_range([start_time, end_time, end_time]) }.to raise_exception ArgumentError
        end
      end
    end

    context "when passed a string or a symbol" do
      it "tries to parse it" do
        range = stub('range')
        Sleek::Timeframe.should_receive(:to_range).with('this_day').and_return range
        expect(Sleek::Timeframe.to_range('this_day')).to eq range
      end
    end
  end

  describe ".parse" do
    context "when passed the proper string" do
      it "parses the string and returns time range" do
        td = Sleek::Timeframe.parse('this_day')
        expect(td.begin).to eq Time.now.beginning_of_day
        expect(td.end).to eq Time.now.end_of_day.round

        p2w = Sleek::Timeframe.parse('previous_2_weeks')
        expect(p2w.begin).to eq Time.now.beginning_of_week - 2.weeks
        expect(p2w.end).to eq Time.now.end_of_week.round - 1.weeks
      end
    end

    context "when passed malformed string" do
      it "raises an exception" do
        expect { Sleek::Timeframe.parse('lol_wut') }.to raise_exception ArgumentError, "special timeframe string is malformed"
      end
    end
  end
end
