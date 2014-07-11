require 'spec_helper'

describe 'feeds/yourcmc_ssh-ip_reputation.feed', :feed do
  let(:provider) { 'yourcmc' }
  let(:name) { 'ssh-ip_reputation' }

  it_fetches_url 'http://vmx.yourcmc.ru/BAD_HOSTS.IP4'

  describe_parsing_the_file feed_data('yourcmc_ssh-ip_reputation.txt') do
    it "should have parsed 16 records" do
      expect(num_records_parsed).to eq(16)
    end
    it "should have filtered 11 records" do
      expect(num_records_filtered).to eq(11)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record '109.120.157.63' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
    describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to match_array(['109.120.157.63']) }
    end
  end

  describe_parsing_a_record '109.165.15.113' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
    describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to match_array(['109.165.15.113']) }
    end
  end
end


