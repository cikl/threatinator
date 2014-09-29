require 'spec_helper'

describe 'feeds/openbl-ip_reputation.feed', :feed do
  let(:provider) { 'openbl' }
  let(:name) { 'ip_reputation' }

  it_fetches_url 'http://www.openbl.org/lists/base.txt'

  describe_parsing_the_file feed_data('openbl_iplist.txt') do
    it "should have parsed 8 records" do
      expect(num_records_parsed).to eq(8)
    end
    it "should have filtered 4 records" do
      expect(num_records_filtered).to eq(4)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record '113.171.10.37' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['113.171.10.37'])) }
    end
  end

  describe_parsing_a_record '210.209.84.57' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['210.209.84.57'])) }
    end
  end
end


