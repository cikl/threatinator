require 'spec_helper'

describe 'feeds/blocklist_de_ftp-ip_reputation.feed', :feed do
  let(:provider) { 'blocklist_de' }
  let(:name) { 'ftp_ip_reputation' }

  it_fetches_url 'http://www.blocklist.de/lists/ftp.txt'

  describe_parsing_the_file feed_data('blocklist_de_ftp-ip-reputation.txt') do
    it "should have parsed 7 records" do
      expect(num_records_parsed).to eq(7)
    end
    it "should have filtered 0 records" do
      expect(num_records_filtered).to eq(0)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record '111.192.138.169' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['111.192.138.169'])) }
    end
  end

  describe_parsing_a_record '112.198.77.229' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['112.198.77.229'])) }
    end
  end
end


