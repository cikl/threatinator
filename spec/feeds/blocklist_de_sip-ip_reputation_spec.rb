require 'spec_helper'

describe 'feeds/blocklist_de_sip-ip_reputation.feed', :feed do
  let(:provider) { 'blocklist_de' }
  let(:name) { 'sip_ip_reputation' }

  it_fetches_url 'http://www.blocklist.de/lists/sip.txt'

  describe_parsing_the_file feed_data('blocklist_de_sip-ip-reputation.txt') do
    it "should have parsed 9 records" do
      expect(num_records_parsed).to eq(9)
    end
    it "should have filtered 0 records" do
      expect(num_records_filtered).to eq(0)
    end
  end

  describe_parsing_a_record '178.32.229.159' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to eq(build(:ipv4s, values: ['178.32.229.159'])) }
    end
  end

  describe_parsing_a_record '198.204.224.10' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to eq(build(:ipv4s, values: ['198.204.224.10'])) }
    end
  end
end


