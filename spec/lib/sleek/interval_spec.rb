require 'spec_helper'

describe Sleek::Interval do
  describe "#initialize" do
    it "transforms interval description into value" do
      Sleek::Interval.should_receive(:interval_value).with(:hourly)
      Sleek::Interval.new(:hourly, Sleek::Timeframe.new(Time.now.all_day))
    end
  end

  describe "#timeframes" do
    it "slices timeframe into interval-long timeframes" do
      bd = Time.now.beginning_of_day
      interval = Sleek::Interval.new(:hourly, Sleek::Timeframe.new(Time.now.all_day))
      expect(interval.timeframes.count).to eq 23

      23.times do |i|
        subtf = interval.timeframes[i]
        expect(subtf.start).to eq bd + 1.hour * i
        expect(subtf.end).to eq bd + 1.hour * (i + 1)
      end
    end
  end
end
