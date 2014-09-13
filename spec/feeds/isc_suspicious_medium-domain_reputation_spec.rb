require 'spec_helper'

describe 'feeds/isc_suspicious_medium-domain_reputation.feed', :feed do
  let(:provider) { 'isc' }
  let(:name) { 'suspicious_medium_domain_reputation' }

  it_fetches_url 'https://isc.sans.edu/feeds/suspiciousdomains_Medium.txt'

  describe_parsing_the_file feed_data('isc_suspicious_medium_domainlist.txt') do
    it "should have parsed 15 records" do
      expect(num_records_parsed).to eq(15)
    end
    it "should have filtered 17 records" do
      expect(num_records_filtered).to eq(17)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record '114oldest.com' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:malware_host) }
      its(:fqdns) { is_expected.to match_array(['114oldest.com']) }
    end
  end

  describe_parsing_a_record '168asia.com' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:malware_host) }
      its(:fqdns) { is_expected.to match_array(['168asia.com']) }
    end
  end
end


