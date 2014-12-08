require 'spec_helper'

describe 'feeds/bambenek_c2_masterlist-domain_reputation.feed', :feed do
  let(:provider) { 'bambenek' }
  let(:name) { 'c2_masterlist' }

  it_fetches_url 'http://osint.bambenekconsulting.com/feeds/c2-dommasterlist.txt'

  describe_parsing_the_file feed_data('bambenek_c2-dommasterlist.csv') do
    it "should have parsed 14 records" do
      expect(num_records_parsed).to eq(14)
    end
    it "should have filtered 16 records" do
      expect(num_records_filtered).to eq(16)
    end
  end

  describe_parsing_a_record 'hhvohslwvpww.ru,Domain used by tinba,2014-11-03 16:30,http://osint.bambenekconsulting.com/manual/tinba-iplist.txt' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
      its(:fqdns) { is_expected.to match_array(['hhvohslwvpww.ru']) }
    end
  end

  describe_parsing_a_record '## jcb@bambenekconsulting.com // http://bambenekconsulting.com' do
    it "should have been filtered" do
      expect(status).to eq(:filtered)
    end
  end
end


