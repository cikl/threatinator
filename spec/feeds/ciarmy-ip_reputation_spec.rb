require 'spec_helper'

describe 'feeds/ciarmy-ip_reputation.feed', :feed do
  let(:provider) { 'ciarmy' }
  let(:name) { 'ip_reputation' }

  it_fetches_url 'http://www.ciarmy.com/list/ci-badguys.txt'

  describe_parsing_the_file feed_data('ciarmy-ip-reputation.txt') do
    it "should have parsed 11 records" do
      expect(num_records_parsed).to eq(11)
    end
    it "should have filtered 0 records" do
      expect(num_records_filtered).to eq(0)
    end
  end

  describe_parsing_a_record '5.79.68.161' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['5.79.68.161'])) }
    end
  end

  describe_parsing_a_record '10.0.100.121' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['10.0.100.121'])) }
    end
  end
end


