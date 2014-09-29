require 'spec_helper'

describe 'feeds/zeus-domain_reputation.feed', :feed do
  let(:provider) { 'abuse_ch' }
  let(:name) { 'zeus_domain_reputation' }

  it_fetches_url 'https://zeustracker.abuse.ch/blocklist.php?download=domainblocklist'

  describe_parsing_the_file feed_data('zeus_domainlist.txt') do
    it "should have parsed 21 records" do
      expect(num_records_parsed).to eq(21)
    end
    it "should have filtered 6 records" do
      expect(num_records_filtered).to eq(6)
    end
  end

  describe_parsing_a_record 'aconfideeeeeracia200.com' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
      its(:fqdns) { is_expected.to match_array(["aconfideeeeeracia200.com"]) }
    end
  end

  describe_parsing_a_record 'advanc420.co.vu' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
      its(:fqdns) { is_expected.to match_array(["advanc420.co.vu"]) }
    end
  end
end


