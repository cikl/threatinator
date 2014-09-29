require 'spec_helper'

describe 'feeds/blocklist_de_apache-ip_reputation.feed', :feed do
  let(:provider) { 'blocklist_de' }
  let(:name) { 'apache_ip_reputation' }

  it_fetches_url 'http://www.blocklist.de/lists/apache.txt'

  describe_parsing_the_file feed_data('blocklist_de_apache-ip-reputation.txt') do
    it "should have parsed 15 records" do
      expect(num_records_parsed).to eq(15)
    end
    it "should have filtered 2 records" do
      expect(num_records_filtered).to eq(2)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record '109.228.235.167' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['109.228.235.167'])) }
    end
  end

  describe_parsing_a_record '109.70.54.11' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['109.70.54.11'])) }
    end
  end
end


