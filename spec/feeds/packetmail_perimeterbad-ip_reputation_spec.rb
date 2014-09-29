require 'spec_helper'

describe 'feeds/packetmail_perimeterbad-ip_reputation.feed', :feed do
  let(:provider) { 'packetmail' }
  let(:name) { 'perimeterbad_ip_reputation' }

  it_fetches_url 'https://www.packetmail.net/iprep_perimeterbad.txt'

  describe_parsing_the_file feed_data('packetmail_perimeterbad-ip_reputation.txt') do
    it "should have parsed 8 records" do
      expect(num_records_parsed).to eq(8)
    end
    it "should have filtered 36 records" do
      expect(num_records_filtered).to eq(36)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record '[03/Sep/2014:13:11:47 -0500]	192.99.152.38	206.82.85.197	403	GET /cc/process.php HTTP/1.1    -	Mozilla/5.0 (Windows NT 6.1; WOW64; rv:8.0) Gecko/20100101 Firefox/8.0	2014-09-03' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to match_array(['192.99.152.38']) }
    end
  end

  describe_parsing_a_record '[03/Sep/2014:18:06:59 -0500]	69.28.85.204	www.hackbraten.tk	403	HEAD /Hackbraten.zip HTTP/1.1   -	curl/7.32.0	2014-09-03' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to match_array(['69.28.85.204']) }
    end
  end
end


