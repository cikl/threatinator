require 'spec_helper'

describe 'feeds/palevo-ip_reputation.feed', :feed do
  let(:provider) { 'abuse_ch' }
  let(:name) { 'palevo_ip_reputation' }

  it_fetches_url 'https://palevotracker.abuse.ch/blocklists.php?download=ipblocklist'

  describe_parsing_the_file feed_data('palevo_iplist.txt') do
    it "should have parsed 23 records" do
      expect(num_records_parsed).to eq(23)
    end
    it "should have filtered 1 records" do
      expect(num_records_filtered).to eq(1)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record '187.214.120.147' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
      its(:ipv4s) { is_expected.to match_array(['187.214.120.147']) }
    end
  end

  describe_parsing_a_record '67.210.170.169' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
      its(:ipv4s) { is_expected.to match_array(['67.210.170.169']) }
    end
  end
end


