require 'spec_helper'

describe 'feeds/spyeye-domain_reputation.feed', :feed do
  let(:provider) { 'abuse_ch' }
  let(:name) { 'spyeye_domain_reputation' }

  it_fetches_url 'https://spyeyetracker.abuse.ch/blocklist.php?download=domainblocklist'

  describe_parsing_the_file feed_data('spyeye_domainlist.txt') do
    it "should have parsed 9 records" do
      expect(num_records_parsed).to eq(9)
    end
    it "should have filtered 7 records" do
      expect(num_records_filtered).to eq(7)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record 'futuretelefonica.com' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
      its(:fqdns) { is_expected.to match_array(["futuretelefonica.com"]) }
    end
  end

  describe_parsing_a_record 'helen33nasanorth.com' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
      its(:fqdns) { is_expected.to match_array(["helen33nasanorth.com"]) }
    end
  end
end


