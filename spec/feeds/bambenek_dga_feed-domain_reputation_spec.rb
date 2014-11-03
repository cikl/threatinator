require 'spec_helper'

describe 'feeds/bambenek_dga_feed-domain_reputation.feed', :feed do
  let(:provider) { 'bambenek' }
  let(:name) { 'dga_feed' }

  it_fetches_url 'http://osint.bambenekconsulting.com/feeds/dga-feed.txt'

  describe_parsing_the_file feed_data('bambenek_dga_feed.csv') do
    it "should have parsed 28 records" do
      expect(num_records_parsed).to eq(28)
    end
    it "should have filtered 14 records" do
      expect(num_records_filtered).to eq(14)
    end
  end

  describe_parsing_a_record 'rjfifeogqukyjdw.ru,Domain used by Wikipedia 25 DGA for 01 Nov 2014,20141101,http://osint.bambenekconsulting.com/manual/wiki25.txt' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
      its(:fqdns) { is_expected.to match_array(['rjfifeogqukyjdw.ru']) }
    end
  end

  describe_parsing_a_record '## http://osint.bambenekconsulting.com/manual/dga-feed.txt' do
    it "should have been filtered" do
      expect(status).to eq(:filtered)
    end
  end
end


