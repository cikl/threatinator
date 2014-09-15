require 'spec_helper'

describe 'feeds/snort_bpf-ip_reputation.feed', :feed do
  let(:provider) { 'snort' }
  let(:name) { 'bpf_ip_reputation' }

  it_fetches_url 'http://labs.snort.org/feeds/ip-filter.blf'

  describe_parsing_the_file feed_data('snort_bpf-ip_reputation.txt') do
    it "should have parsed 16 records" do
      expect(num_records_parsed).to eq(16)
    end
    it "should have filtered 0 records" do
      expect(num_records_filtered).to eq(0)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record '193.106.31.12' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to match_array(['193.106.31.12']) }
    end
  end

  describe_parsing_a_record '76.74.184.23' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to match_array(['76.74.184.23']) }
    end
  end
end


