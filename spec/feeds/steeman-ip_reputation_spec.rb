require 'spec_helper'

describe 'feeds/steeman-ip_reputation.feed', :feed do
  let(:provider) { 'steeman' }
  let(:name) { 'ip_reputation' }

  it_fetches_url 'http://jeroen.steeman.org/FS-PlainText'

  describe_parsing_the_file feed_data('steeman-ip-reputation.txt') do
    it "should have parsed 11 records" do
      expect(num_records_parsed).to eq(11)
    end
    it "should have filtered 2 records" do
      expect(num_records_filtered).to eq(2)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record '1.10.221.78' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
	  its(:ipv4s) { is_expected.to eq(build(:ipv4s, values: ['1.10.221.78'])) }
    end
  end

  describe_parsing_a_record '1.168.163.133' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
	  its(:ipv4s) { is_expected.to eq(build(:ipv4s, values: ['1.168.163.133'])) }
    end
  end
end


