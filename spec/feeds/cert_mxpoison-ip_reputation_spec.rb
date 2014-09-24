require 'spec_helper'

describe 'feeds/cert_mxpoison-ip_reputation.feed', :feed do
  let(:provider) { 'cert' }
  let(:name) { 'mxpoison_ip_reputation' }

  it_fetches_url 'http://www.cert.org/downloads/mxlist.ips.txt'

  describe_parsing_the_file feed_data('cert_mxpoison-ip_reputation.txt') do
    it "should have parsed 17 records" do
      expect(num_records_parsed).to eq(17)
    end
    it "should have filtered 0 records" do
      expect(num_records_filtered).to eq(0)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record '74.125.196.27' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:malware_host) }
      its(:ipv4s) { is_expected.to match_array(['74.125.196.27']) }
    end
  end

  describe_parsing_a_record '74.53.119.26' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:malware_host) }
      its(:ipv4s) { is_expected.to match_array(['74.53.119.26']) }
    end
  end
end


