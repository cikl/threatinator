require 'spec_helper'

describe 'feeds/malc0de-ip_reputation.feed', :feed do
  let(:provider) { 'malc0de' }
  let(:name) { 'ip_reputation' }

  it_fetches_url 'http://malc0de.com/bl/IP_Blacklist.txt'

  describe_parsing_the_file feed_data('malc0de_iplist.txt') do
    it "should have parsed 10 records" do
      expect(num_records_parsed).to eq(10)
    end
    it "should have filtered 4 records" do
      expect(num_records_filtered).to eq(4)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record '216.151.164.53' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:malware_host) }
      its(:ipv4s) { is_expected.to match_array(['216.151.164.53']) }
    end
  end

  describe_parsing_a_record '176.32.99.47' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:malware_host) }
      its(:ipv4s) { is_expected.to match_array(['176.32.99.47']) }
    end
  end
end


