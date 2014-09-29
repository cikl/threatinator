require 'spec_helper'

describe 'feeds/autoshun_shunlist.feed', :feed do
  let(:provider) { 'autoshun' }
  let(:name) { 'shunlist' }

  it_fetches_url 'http://www.autoshun.org/files/shunlist.csv'

  describe_parsing_the_file feed_data('autoshun_shunlist.csv') do
    it "should have parsed 19 records" do
      expect(num_records_parsed).to eq(19)
    end
    it "should have filtered 1 records" do
      expect(num_records_filtered).to eq(1)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record '1.93.34.230,2014-07-16 08:01:23,SSH Brute Force' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
    describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['1.93.34.230'])) }
    end
  end

  describe_parsing_a_record 'Shunlist as of Mon, 21 Jul 2014 13:30:02 -0500' do
    it "should have been filtered" do
      expect(status).to eq(:filtered)
    end
  end
end


