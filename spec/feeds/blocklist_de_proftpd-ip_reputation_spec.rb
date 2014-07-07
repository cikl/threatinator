require 'spec_helper'

describe 'feeds/blocklist_de_proftpd-ip_reputation.feed', :feed do
  let(:provider) { 'blocklist_de' }
  let(:name) { 'proftpd_ip_reputation' }

  it_fetches_url 'http://www.blocklist.de/lists/proftpd.txt'

  describe_parsing_the_file feed_data('blocklist_de_proftpd-ip-reputation.txt') do
    it "should have parsed 12 records" do
      expect(num_records_parsed).to eq(12)
    end
    it "should have filtered 0 records" do
      expect(num_records_filtered).to eq(0)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record '111.192.148.129' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to match_array(['111.192.148.129']) }
    end
  end

  describe_parsing_a_record '112.90.37.220' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to match_array(['112.90.37.220']) }
    end
  end
end


