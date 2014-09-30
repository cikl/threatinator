require 'spec_helper'

describe 'feeds/isc_suspicious_high-domain_reputation.feed', :feed do
  let(:provider) { 'isc' }
  let(:name) { 'suspicious_high_domain_reputation' }

  it_fetches_url 'https://isc.sans.edu/feeds/suspiciousdomains_High.txt'

  describe_parsing_the_file feed_data('isc_suspicious_high_domainlist.txt') do
    it "should have parsed 9 records" do
      expect(num_records_parsed).to eq(9)
    end
    it "should have filtered 17 records" do
      expect(num_records_filtered).to eq(17)
    end
  end

  describe_parsing_a_record '1-verygoods.ru' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:malware_host) }
      its(:fqdns) { is_expected.to match_array(['1-verygoods.ru']) }
    end
  end

  describe_parsing_a_record '123kochi.com' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:malware_host) }
      its(:fqdns) { is_expected.to match_array(['123kochi.com']) }
    end
  end
end


