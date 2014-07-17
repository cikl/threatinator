require 'spec_helper'

describe 'feeds/feodo-ip_reputation.feed', :feed do
  let(:provider) { 'abuse_ch' }
  let(:name) { 'feodo_ip_reputation' }

  it_fetches_url 'https://feodotracker.abuse.ch/blocklist.php?download=ipblocklist'

  describe_parsing_the_file feed_data('feodo_iplist.txt') do
    it "should have parsed 14 records" do
      expect(num_records_parsed).to eq(14)
    end
    it "should have filtered 6 records" do
      expect(num_records_filtered).to eq(6)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record '103.25.59.120' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
      its(:ipv4s) { is_expected.to match_array(['103.25.59.120']) }
    end
  end

  describe_parsing_a_record '173.236.86.214' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
      its(:ipv4s) { is_expected.to match_array(['173.236.86.214']) }
    end
  end
end


