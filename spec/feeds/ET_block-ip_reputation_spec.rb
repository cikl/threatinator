require 'spec_helper'

describe 'feeds/ET_block-ip_reputation.feed', :feed do
  let(:provider) { 'emergingthreats' }
  let(:name) { 'block_ip_reputation' }

  it_fetches_url 'http://rules.emergingthreats.net/fwrules/emerging-Block-IPs.txt'

  describe_parsing_the_file feed_data('ET_block-ip_reputation.txt') do
    it "should have parsed 12 records" do
      expect(num_records_parsed).to eq(12)
    end
    it "should have filtered 68 records" do
      expect(num_records_filtered).to eq(68)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record '103.230.84.239' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
	  its(:ipv4s) { is_expected.to eq(build(:ipv4s, values: ['103.230.84.239'])) }
    end
  end

  describe_parsing_a_record '97.107.134.249' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
	  its(:ipv4s) { is_expected.to eq(build(:ipv4s, values: ['97.107.134.249'])) }
    end
  end
end


