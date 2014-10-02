require 'spec_helper'

describe 'feeds/bitcash_cz_blacklist.feed', :feed do
  let(:provider) { 'bitcash_cz' }
  let(:name) { 'blacklist' }

  it_fetches_url 'http://bitcash.cz/misc/log/blacklist'

  describe_parsing_the_file feed_data('bitcash_cz_blacklist.txt') do
    it "should have parsed 3 records" do
      expect(num_records_parsed).to eq(3)
    end
    it "should have filtered 4 records" do
      expect(num_records_filtered).to eq(4)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record '107.22.93.75 #    ec2-107-22-93-75.compute-1.amazonaws.com       last access 2014-07-30 01:45:02' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
	  its(:ipv4s) { is_expected.to eq(build(:ipv4s, values: ['107.22.93.75'])) }
    end
  end

  describe_parsing_a_record '195.98.179.106 #  broadband-195-98-179-106.2com.net              last access 2014-09-02 17:01:01' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
	  its(:ipv4s) { is_expected.to eq(build(:ipv4s, values: ['195.98.179.106'])) }
    end
  end
end


