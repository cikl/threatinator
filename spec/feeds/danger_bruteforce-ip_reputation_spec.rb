require 'spec_helper'

describe 'feeds/danger_bruteforce-ip_reputation.feed', :feed do
  let(:provider) { 'danger' }
  let(:name) { 'bruteforce_ip_reputation' }

  it_fetches_url 'http://danger.rulez.sk/projects/bruteforceblocker/blist.php'

  describe_parsing_the_file feed_data('danger_bruteforce-ip_reputation.txt') do
    it "should have parsed 11 records" do
      expect(num_records_parsed).to eq(11)
    end
    it "should have filtered 1 records" do
      expect(num_records_filtered).to eq(1)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record '192.168.0.66            # 2014-07-02 16:01:22           148     532953' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to match_array(['192.168.0.66']) }
    end
  end

  describe_parsing_a_record '125.65.245.146          # 2014-07-06 16:04:46           64      359660' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to match_array(['125.65.245.146']) }
    end
  end
end


