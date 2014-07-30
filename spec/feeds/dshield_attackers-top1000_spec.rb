require 'spec_helper'

describe 'feeds/dshield_attackers-top1000.feed', :feed do
  let(:provider) { 'dshield' }
  let(:name) { 'attackers-top1000' }

  it_fetches_url 'https://isc.sans.edu/api/sources/attacks/1000/'

  describe_parsing_the_file feed_data('dshield_topattackers.xml') do
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
      let(:record_reports) { feed_report.record_reports }
      it "should total 10" do
        expect(record_reports.count).to eq(10)
      end

      it "each record should have generated exactly one event" do
        counts = record_reports.map { |rr| rr.events.count }
        expect(counts).to eq([1,1,1,1,1,1,1,1,1,1])
      end

      describe "the event for record 0" do
        let(:record_report) { record_reports[0] }
        let(:record) { record_report.record }
        let(:event) { record_report.events.first }
        subject { event } 

        its(:type) { is_expected.to be(:attacker) }
        its(:ipv4s) { is_expected.to match_array(['150.164.82.10']) }
      end
    end
  end
end



