require 'spec_helper'

describe 'feeds/blocklist_de_pop3-ip_reputation.feed', :feed do
  let(:provider) { 'blocklist_de' }
  let(:name) { 'pop3_ip_reputation' }

  it_fetches_url 'http://www.blocklist.de/lists/pop3.txt'

  describe_parsing_the_file feed_data('blocklist_de_pop3-ip-reputation.txt') do
    it "should have parsed 11 records" do
      expect(num_records_parsed).to eq(11)
    end
    it "should have filtered 0 records" do
      expect(num_records_filtered).to eq(0)
    end
  end

  describe_parsing_a_record '1.175.64.9' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['1.175.64.9'])) }
    end
  end

  describe_parsing_a_record '1.53.0.215' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['1.53.0.215'])) }
    end
  end
end


