require 'spec_helper'

describe 'feeds/trustedsec-ip_reputation.feed', :feed do
  let(:provider) { 'trustedsec' }
  let(:name) { 'ip_reputation' }

  it_fetches_url 'https://www.trustedsec.com/banlist.txt'

  describe_parsing_the_file feed_data('trustedsec-ip-reputation.txt') do
    it "should have parsed 11 records" do
      expect(num_records_parsed).to eq(11)
    end
    it "should have filtered 1 records" do
      expect(num_records_filtered).to eq(1)
    end
  end

  describe_parsing_a_record '100.42.74.90' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['100.42.74.90'])) }
    end
  end

  describe_parsing_a_record '101.108.127.106' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['101.108.127.106'])) }
    end
  end
end


