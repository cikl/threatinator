require 'spec_helper'

describe 'feeds/alienvault-ip_reputation.feed', :feed do
  let(:provider) { 'alienvault' }
  let(:name) { 'ip_reputation' }

  it_fetches_url 'https://reputation.alienvault.com/reputation.generic'

  describe_parsing_the_file feed_data('alienvault-ip_reputation.txt') do
    it "should have parsed 10 records" do
      expect(num_records_parsed).to eq(10)
    end
    it "should have filtered 8 records" do
      expect(num_records_filtered).to eq(8)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record '37.205.198.162 # Scanning Host IT,,42.8333015442,12.8332996368' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
    describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to match_array(['37.205.198.162']) }
    end
  end

  describe_parsing_a_record '108.59.1.5 # Scanning Host A1,,0.0,0.0' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
    describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to match_array(['108.59.1.5']) }
    end
  end
end


