require 'spec_helper'

describe 'feeds/infiltrated-ip_reputation.feed', :feed do
  let(:provider) { 'infiltrated' }
  let(:name) { 'ip_reputation' }

  it_fetches_url 'http://www.infiltrated.net/blacklisted'

  describe_parsing_the_file feed_data('infiltrated_iplist.txt') do
    it "should have parsed 14 records" do
      expect(num_records_parsed).to eq(14)
    end
    it "should have filtered 2 records" do
      expect(num_records_filtered).to eq(2)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record '95.221.71.219' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['95.221.71.219'])) }
    end
  end

  describe_parsing_a_record '94.41.71.52' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['94.41.71.52'])) }
    end
  end
end


