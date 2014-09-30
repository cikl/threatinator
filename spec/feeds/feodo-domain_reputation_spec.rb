require 'spec_helper'

describe 'feeds/feodo-domain_reputation.feed', :feed do
  let(:provider) { 'abuse_ch' }
  let(:name) { 'feodo_domain_reputation' }

  it_fetches_url 'https://feodotracker.abuse.ch/blocklist.php?download=domainblocklist'

  describe_parsing_the_file feed_data('feodo_domainlist.txt') do
    it "should have parsed 12 records" do
      expect(num_records_parsed).to eq(12)
    end
    it "should have filtered 6 records" do
      expect(num_records_filtered).to eq(6)
    end
  end

  describe_parsing_a_record 'buriymishka.ru' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
      its(:fqdns) { is_expected.to match_array(['buriymishka.ru']) }
    end
  end

  describe_parsing_a_record 'hawozkino.com' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
      its(:fqdns) { is_expected.to match_array(['hawozkino.com']) }
    end
  end
end


