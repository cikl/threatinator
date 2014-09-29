require 'spec_helper'

describe 'feeds/malc0de-domain_reputation.feed', :feed do
  let(:provider) { 'malc0de' }
  let(:name) { 'domain_reputation' }

  it_fetches_url 'http://malc0de.com/bl/BOOT'

  describe_parsing_the_file feed_data('malc0de_domainlist.txt') do
    it "should have parsed 12 records" do
      expect(num_records_parsed).to eq(12)
    end
    it "should have filtered 6 records" do
      expect(num_records_filtered).to eq(6)
    end
  end

  describe_parsing_a_record 'PRIMARY opencandy.com blockeddomain.hosts' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:malware_host) }
      its(:fqdns) { is_expected.to match_array(['opencandy.com']) }
    end
  end

  describe_parsing_a_record 'PRIMARY cachelocal.org blockeddomain.hosts' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:malware_host) }
      its(:fqdns) { is_expected.to match_array(['cachelocal.org']) }
    end
  end
end


