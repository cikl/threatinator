require 'spec_helper'

describe 'feeds/falconcrest-ip_reputation.feed', :feed do
  let(:provider) { 'falconcrest' }
  let(:name) { 'ip_reputation' }

  it_fetches_url 'http://www.falconcrest.eu/IPBL.aspx'

  describe_parsing_the_file feed_data('falconcrest_iplist.txt') do
    it "should have parsed 10 records" do
      expect(num_records_parsed).to eq(29)
    end
    it "should have filtered 0 records" do
      expect(num_records_filtered).to eq(0)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end

    describe "the records" do
      it "should total 10" do
        expect(num_records).to eq(29)
      end

      it "each record should have generated exactly one event" do
        counts = events.map { |event_array| event_array.count }
        expect(counts).to eq([1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1])
      end

      describe "the event for record 0" do
        let(:record) { records[0] }
        let(:event) { events[0].first }
        subject { event } 

        its(:type) { is_expected.to be(:spamming) }
        its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['175.44.5.227'])) }
      end
    end
  end
end
