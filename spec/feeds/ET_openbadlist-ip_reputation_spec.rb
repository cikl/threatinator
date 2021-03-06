require 'spec_helper'

describe 'feeds/ET_openbadlist-ip_reputation.feed', :feed do
  let(:provider) { 'emergingthreats' }
  let(:name) { 'openbadlist_ip_reputation' }

  it_fetches_url 'https://raw.githubusercontent.com/EmergingThreats/et-open-bad-ip-list/master/IPs.txt'

  describe_parsing_the_file feed_data('ET_openbadlist-ip_reputation.txt') do
    it "should have parsed 44 records" do
      expect(num_records_parsed).to eq(44)
    end
    it "should have filtered 18 records" do
      expect(num_records_filtered).to eq(18)
    end
  end


  describe_parsing_a_record 'Feb 18 2014; 89.45.14.0/24; Infinity/Redkit2/Goon EK landing or EK gate.' do
    it "should have been filtered" do
      expect(status).to eq(:filtered)
    end
    it "should have parsed 0 events" do
      expect(events.count).to eq(0)
    end
  end
  describe_parsing_a_record 'Jan 24 2014; 212.83.160.187/32; Neutrino EK' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
      its(:ipv4s) { is_expected.to eq(build(:ipv4s, values: ['212.83.160.187'])) }
    end
  end

  describe_parsing_a_record 'Jan 28 2014; 149.154.64.180/32; [a-z]{3,6}\.pp\.ua DGA cesspool' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
      its(:ipv4s) { is_expected.to eq(build(:ipv4s, values: ['149.154.64.180'])) }
    end
  end
end


