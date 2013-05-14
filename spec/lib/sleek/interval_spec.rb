require 'spec_helper'

describe Sleek::Interval do
  describe "#initialize" do
    it "transforms interval description into value" do
      described_class.should_receive(:interval_value).with(:hourly)
      described_class.new(:hourly, Time.now.all_day)
    end
  end

  describe "#timeframes" do
    it "slices timeframe into interval-long timeframes" do
      now = ActiveSupport::TimeZone.new('UTC').now
      bd = now.beginning_of_day
      interval = described_class.new(:hourly, now.all_day)
      expect(interval.timeframes.count).to eq 23

      23.times do |i|
        subtf = interval.timeframes[i]
        expect(subtf.begin).to eq bd + 1.hour * i
        expect(subtf.end).to eq bd + 1.hour * (i + 1)
      end
    end
  end
end
