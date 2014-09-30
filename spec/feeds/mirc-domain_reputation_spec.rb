require 'spec_helper'

describe 'feeds/mirc-domain_reputation.feed', :feed do
  let(:provider) { 'mirc' }
  let(:name) { 'domain_reputation' }

  it_fetches_url 'http://www.mirc.com/servers.ini'

  describe_parsing_the_file feed_data('mirc_domainlist.txt') do
    it "should have parsed 13 records" do
      expect(num_records_parsed).to eq(13)
    end
    it "should have filtered 18 records" do
      expect(num_records_filtered).to eq(18)
    end
  end

  describe_parsing_a_record 'n3=Random US serverSERVER:irc.us.dal.net:6665-6668,7000GROUP:DALnet' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
      its(:fqdns) { is_expected.to match_array(['irc.us.dal.net']) }
    end
  end

  describe_parsing_a_record 'n7=US, WA, SeattleSERVER:serverbuffet.wa.us.dal.net:6665-6668,7000GROUP:DALnet' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
      its(:fqdns) { is_expected.to match_array(['serverbuffet.wa.us.dal.net']) }
    end
  end
end


