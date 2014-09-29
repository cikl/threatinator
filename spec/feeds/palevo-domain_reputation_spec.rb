require 'spec_helper'

describe 'feeds/palevo-domain_reputation.feed', :feed do
  let(:provider) { 'abuse_ch' }
  let(:name) { 'palevo_domain_reputation' }

  it_fetches_url 'https://palevotracker.abuse.ch/blocklists.php?download=domainblocklist'

  describe_parsing_the_file feed_data('palevo_domainlist.txt') do
    it "should have parsed 24 records" do
      expect(num_records_parsed).to eq(24)
    end
    it "should have filtered 1 records" do
      expect(num_records_filtered).to eq(1)
    end
  end

  describe_parsing_a_record 'legionarios.servecounterstrike.com' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
      its(:fqdns) { is_expected.to match_array(['legionarios.servecounterstrike.com']) }
    end
  end

  describe_parsing_a_record 's.24otuwotefsmd.com' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
      its(:fqdns) { is_expected.to match_array(['s.24otuwotefsmd.com']) }
    end
  end
end


