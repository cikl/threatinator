require 'spec_helper'

describe 'feeds/dan_me_uk_torlist-ip_reputation.feed', :feed do
  let(:provider) { 'dan_me_uk' }
  let(:name) { 'torlist_ip_reputation' }

  it_fetches_url 'https://www.dan.me.uk/torlist/'

  describe_parsing_the_file feed_data('dan_me_uk_torlist-ip-reputation.txt') do
    it "should have parsed 11 records" do
      expect(num_records_parsed).to eq(11)
    end
    it "should have filtered 0 records" do
      expect(num_records_filtered).to eq(0)
    end
  end

  describe_parsing_a_record '100.34.32.230' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['100.34.32.230'])) }
    end
  end

  describe_parsing_a_record '101.55.12.75' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['101.55.12.75'])) }
    end
  end
end


