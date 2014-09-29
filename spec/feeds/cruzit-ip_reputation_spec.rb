require 'spec_helper'

describe 'feeds/cruzit-ip_reputation.feed', :feed do
  let(:provider) { 'cruzit' }
  let(:name) { 'ip_reputation' }

  it_fetches_url 'http://www.cruzit.com/xwbl2txt.php'

  describe_parsing_the_file feed_data('cruzit-ip-reputation.txt') do
    it "should have parsed 14 records" do
      expect(num_records_parsed).to eq(14)
    end
    it "should have filtered 0 records" do
      expect(num_records_filtered).to eq(0)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record '107.170.248.56' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['107.170.248.56'])) }
    end
  end

  describe_parsing_a_record '80.82.64.114' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['80.82.64.114'])) }
    end
  end
end


