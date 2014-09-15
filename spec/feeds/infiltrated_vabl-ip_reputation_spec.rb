require 'spec_helper'

describe 'feeds/infiltrated_vabl-ip_reputation.feed', :feed do
  let(:provider) { 'infiltrated' }
  let(:name) { 'vabl_ip_reputation' }

  it_fetches_url 'http://www.infiltrated.net/vabl.txt'

  describe_parsing_the_file feed_data('infiltrated_vabl_iplist.txt') do
    it "should have parsed 21 records" do
      expect(num_records_parsed).to eq(21)
    end
    it "should have filtered 12 records" do
      expect(num_records_filtered).to eq(12)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record '108.59.1.205 | BRU | VABL | 20110609 | e22b6e201b3533a0dd1ac8bb47426169 | 30633 | 108.59.0.0/20 | LEASEWEB-US | US | - | LEASEWEB USA INC' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to match_array(['108.59.1.205']) }
    end
  end

  describe_parsing_a_record '109.169.60.121 | BRU | VABL | 20110621 | 8850509672ee7d983d9a511e31b13a9a | 29761 | 109.169.60.0/23 | OC3-NETWORKS-AS-NUMB | US | BMTRADAGROUP.COM | RAPIDSWITCH LTD' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to match_array(['109.169.60.121']) }
    end
  end
end


