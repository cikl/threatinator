require 'spec_helper'

describe 'feeds/vxvault-url_reputation.feed', :feed do
  let(:provider) { 'vxvault' }
  let(:name) { 'url_reputation' }

  it_fetches_url 'http://vxvault.siri-urz.net/URL_List.php'

  describe_parsing_the_file feed_data('vxvault-url-reputation.txt') do
    it "should have parsed 12 records" do
      expect(num_records_parsed).to eq(12)
    end
    it "should have filtered 3 records" do
      expect(num_records_filtered).to eq(3)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record 'http://176.31.228.6/111.exe' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:malware_host) }
	  its(:urls) { is_expected.to eq(build(:urls, values: ['http://176.31.228.6/111.exe'])) }
    end
  end

  describe_parsing_a_record 'http://w719460.blob4.ge.tt/streams/2RLPNJy1/Hawlery.exe?sig=-Uidne-6-hjiAPHjRw-9FCmeKQculOB4naU&type=download' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:malware_host) }
	  its(:urls) { is_expected.to eq(build(:urls, values: ['http://w719460.blob4.ge.tt/streams/2RLPNJy1/Hawlery.exe?sig=-Uidne-6-hjiAPHjRw-9FCmeKQculOB4naU&type=download'])) }
    end
  end
end


