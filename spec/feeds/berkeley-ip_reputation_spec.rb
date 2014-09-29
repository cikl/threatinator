require 'spec_helper'

describe 'feeds/berkeley-ip_reputation.feed', :feed do
  let(:provider) { 'berkeley' }
  let(:name) { 'ip_reputation' }

  it_fetches_url 'https://security.berkeley.edu/aggressive_ips/ips'

  describe_parsing_the_file feed_data('berkeley.txt') do
    it "should have parsed 16 records" do
      expect(num_records_parsed).to eq(16)
    end
    it "should have filtered 13 records" do
      expect(num_records_filtered).to eq(13)
    end
  end

  describe_parsing_a_record 'HOSTILE_IP: 116.10.191.182      LAST_SEEN: 1403615662' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['116.10.191.182'])) }
    end
  end

  describe_parsing_a_record 'HOSTILE_IP: 144.0.0.22  LAST_SEEN: 1404389169' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['144.0.0.22'])) }
    end
  end
end


