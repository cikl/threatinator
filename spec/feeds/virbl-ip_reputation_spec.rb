require 'spec_helper'

describe 'feeds/virbl-ip_reputation.feed', :feed do
  let(:provider) { 'virbl' }
  let(:name) { 'ip_reputation' }

  it_fetches_url 'http://virbl.org/download/virbl.dnsbl.bit.nl.txt'

  describe_parsing_the_file feed_data('virbl-ip_reputation.txt') do
    it "should have parsed 13 records" do
      expect(num_records_parsed).to eq(13)
    end
    it "should have filtered 1 records" do
      expect(num_records_filtered).to eq(1)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record '193.20.147.167' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
    describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:malware_host) }
      its(:ipv4s) { is_expected.to match_array(['193.20.147.167']) }
    end
  end

  describe_parsing_a_record '37.84.148.198' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
    describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:malware_host) }
      its(:ipv4s) { is_expected.to match_array(['37.84.148.198']) }
    end
  end
end


