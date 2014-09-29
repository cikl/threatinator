require 'spec_helper'

describe 'feeds/sigmaproject_spyware.feed', :feed do
  let(:provider) { 'sigmaproject' }
  let(:name) { 'spyware_ip_reputation' }

  it_fetches_url 'https://blocklist.sigmaprojects.org/api.cfc?method=getList&lists=spyware'

  describe_parsing_the_file feed_data('sigmaproject_spyware.return.gz') do
    it "should have parsed 5 records" do
      expect(num_records_parsed).to eq(5)
    end
    it "should have filtered 5 records" do
      expect(num_records_filtered).to eq(5)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end

    describe "the records" do
      it "should total 10" do
        expect(num_records).to eq(10)
      end

      it "each record should have generated exactly one event" do
        counts = events.map { |event_array| event_array.count }
        expect(counts).to eq([1, 0, 0, 0, 0, 0, 1, 1, 1, 1])
      end

      describe "the event for record 0" do
        let(:record) { records[0] }
        let(:event) { events[0].first }
        subject { event } 

        its(:type) { is_expected.to be(:c2) }
        its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['2.60.13.132'])) }
      end
    end
  end
  
  describe_parsing_a_record '2.60.13.132/32' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['2.60.13.132'])) }
    end
  end

  describe_parsing_a_record '5.3.88.23/27' do
    it "should have been filtered" do
      expect(status).to eq(:filtered)
    end
    it "should have no events" do
      expect(events.count).to eq(0)
    end
  end

end



