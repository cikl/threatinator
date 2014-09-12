require 'spec_helper'

describe 'feeds/cydef_torexit-ip_reputation.feed', :feed do
  let(:provider) { 'cydef' }
  let(:name) { 'torexit_ip_reputation' }

  it_fetches_url 'https://cydef.us/torexit.txt'

  describe_parsing_the_file feed_data('cydef_torexit-ip_reputation.txt') do
    it "should have parsed 26 records" do
      expect(num_records_parsed).to eq(26)
    end
    it "should have filtered 1 records" do
      expect(num_records_filtered).to eq(1)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record '5.9.195.140' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to match_array(['5.9.195.140']) }
    end
  end

  describe_parsing_a_record '5.45.104.141' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to match_array(['5.45.104.141']) }
    end
  end
end


