require 'spec_helper'

describe Sleek::Timeframe do
  let(:start_time) { 1.day.ago }
  let(:end_time) { Time.now }
  let(:range) { start_time..end_time }

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
      context "without timezone" do
        it "tries to parse it" do
          Sleek::Timeframe.should_receive(:parse).with('this_day', nil)
          Sleek::Timeframe.to_range('this_day')
        end
      end

      context "with timezone" do
        it "tries to parse it with appropriate timezone" do
          Sleek::Timeframe.should_receive(:parse).with('this_day', 'US/Pacific')
          Sleek::Timeframe.to_range('this_day', 'US/Pacific')
        end
      end
    end

    context "when passed something else" do
      it "raises an exception" do
        expect { Sleek::Timeframe.to_range(some_object: 1) }.to raise_exception ArgumentError
      end
    end
  end

  describe ".parse" do
    context "when passed the proper string" do
      it "creates range from interval and number, preserving timezone" do
        Sleek::Timeframe.should_receive(:range_from_interval).with('day', 2, 'US/Pacific')
        Sleek::Timeframe.parse('this_2_days', 'US/Pacific')
      end

      it "parses the string and returns time range" do
        tz = ActiveSupport::TimeZone.new('UTC')

        td = Sleek::Timeframe.parse('this_day')
        expect(td.begin).to eq tz.now.beginning_of_day
        expect(td.end).to eq tz.now.end_of_day.round

        p2w = Sleek::Timeframe.parse('previous_2_weeks')
        expect(p2w.begin).to eq tz.now.beginning_of_week - 2.weeks
        expect(p2w.end).to eq tz.now.end_of_week.round - 1.weeks
      end
    end

    context "when passed malformed string" do
      it "raises an exception" do
        expect { Sleek::Timeframe.parse('lol_wut') }.to raise_exception ArgumentError, "special timeframe string is malformed"
      end
    end
  end

  describe ".range_from_interval" do
    before { now.stub(:end_of_day) { 2.days } }

    context "without timezone" do
      let(:now) { double('utc_now') }
      before { ActiveSupport::TimeZone.stub_chain(:new, :now).and_return(now) }

      it "creates a range" do
        expect(Sleek::Timeframe.range_from_interval("day", 1)).to eq 1.day..2.days
      end
    end

    context "with timezone" do
      let(:now) { double('local_now') }
      let(:tz) { stub('timezone', now: now) }

      before do
        ActiveSupport::TimeZone.stub(:new).and_return(tz)
      end

      it "gets current time in the timezone" do
        ActiveSupport::TimeZone.should_receive(:new).with('US/Pacific')
        tz.should_receive(:now)

        Sleek::Timeframe.range_from_interval('day', 1, 'US/Pacific')
      end

      it "creates a range" do
        expect(Sleek::Timeframe.range_from_interval('day', 1, 'US/Pacific')).to eq 1.day..2.days
      end
    end
  end
end
