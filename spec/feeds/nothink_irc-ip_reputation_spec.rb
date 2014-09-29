require 'spec_helper'

describe 'feeds/nothink_irc-ip_reputation.feed', :feed do
  let(:provider) { 'nothink' }
  let(:name) { 'irc_ip_reputation' }

  it_fetches_url 'http://www.nothink.org/blacklist/blacklist_malware_irc.txt'

  describe_parsing_the_file feed_data('nothink_irc_iplist.txt') do
    it "should have parsed 11 records" do
      expect(num_records_parsed).to eq(11)
    end
    it "should have filtered 3 records" do
      expect(num_records_filtered).to eq(3)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record '189.107.132.113' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['189.107.132.113'])) }
    end
  end

  describe_parsing_a_record '201.48.61.38' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['201.48.61.38'])) }
    end
  end
end


