require 'spec_helper'

describe 'feeds/arbor_fastflux-domain_reputation.feed', :feed do
  let(:provider) { 'arbor' }
  let(:name) { 'fastflux_domain_reputation' }

  it_fetches_url 'http://atlas.arbor.net/summary/domainlist'

  describe_parsing_the_file feed_data('arbor_domainlist.txt') do
    it "should have parsed 2 records" do
      expect(num_records_parsed).to eq(2)
    end
    it "should have filtered 9 records" do
      expect(num_records_filtered).to eq(9)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record 'brylanehome.com' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
      its(:fqdns) { is_expected.to match_array(['brylanehome.com']) }
    end
  end

  describe_parsing_a_record 'emltrk.com' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
      its(:fqdns) { is_expected.to match_array(['emltrk.com']) }
    end
  end
end


