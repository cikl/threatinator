require 'spec_helper'

describe 'feeds/botscout-ip_reputation.feed', :feed do
  let(:provider) { 'botscout' }
  let(:name) { 'ip_reputation' }

  it_fetches_url 'http://botscout.com/last_caught_cache.htm'

  describe_parsing_the_file feed_data('botscout-ip-reputation.txt') do
    it "should have parsed 100 records" do
      expect(num_records_parsed).to eq(100)
    end
    it "should have filtered 613 records" do
      expect(num_records_filtered).to eq(613)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record '<td><a href="/ipcheck.htm?ip=71.173.145.58">71.173.145.58</a></td>' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
	  its(:ipv4s) { is_expected.to eq(build(:ipv4s, values: ['71.173.145.58'])) }
    end
  end

  describe_parsing_a_record '<td><a href="/ipcheck.htm?ip=91.200.13.5">91.200.13.5</a></td>' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
	  its(:ipv4s) { is_expected.to eq(build(:ipv4s, values: ['91.200.13.5'])) }
    end
  end
end


