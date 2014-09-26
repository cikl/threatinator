require 'spec_helper'

describe 'feeds/sigmaproject_atma.feed', :feed do
  let(:provider) { 'sigmaproject' }
  let(:name) { 'atma_ip_reputation' }

  it_fetches_url 'https://blocklist.sigmaprojects.org/api.cfc?method=getList&lists=atma'

  describe_parsing_the_file feed_data('sigmaproject_atma.return.gz') do
    it "should have parsed 10 records" do
      expect(num_records_parsed).to eq(10)
    end
    it "should have filtered 0 records" do
      expect(num_records_filtered).to eq(0)
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
        expect(counts).to eq([1,1,1,1,1,1,1,1,1,1])
      end

      describe "the event for record 0" do
        let(:record) { records[0] }
        let(:event) { events[0].first }
        subject { event } 

        its(:type) { is_expected.to be(:scanning) }
        its(:ipv4s) { is_expected.to match_array(['106.187.97.158']) }
      end
    end
  end
  
  describe_parsing_a_record '117.194.6.38/32' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to match_array(['117.194.6.38']) }
    end
  end

end



