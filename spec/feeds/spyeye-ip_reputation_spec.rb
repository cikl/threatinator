require 'spec_helper'

describe 'feeds/spyeye-ip_reputation.feed', :feed do
  let(:provider) { 'abuse_ch' }
  let(:name) { 'spyeye_ip_reputation' }

  it_fetches_url 'https://spyeyetracker.abuse.ch/blocklist.php?download=ipblocklist'

  describe_parsing_the_file feed_data('spyeye_iplist.txt') do
    it "should have parsed 12 records" do
      expect(num_records_parsed).to eq(12)
    end
    it "should have filtered 7 records" do
      expect(num_records_filtered).to eq(7)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record '188.190.126.173' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
      its(:ipv4s) { is_expected.to match_array(['188.190.126.173']) }
    end
  end

  describe_parsing_a_record '91.220.62.190' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
      its(:ipv4s) { is_expected.to match_array(['91.220.62.190']) }
    end
  end
end


