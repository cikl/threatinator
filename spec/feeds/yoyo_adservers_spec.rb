require 'spec_helper'

describe 'feeds/yoyo_adservers-domain_reputation.feed', :feed do
  let(:provider) { 'yoyo' }
  let(:name) { 'adservers' }

  it_fetches_url 'http://pgl.yoyo.org/adservers/serverlist.php?hostformat=nohtml'

  describe_parsing_the_file feed_data('yoyo_adservers.txt') do
    it "should have parsed 25 records" do
      expect(num_records_parsed).to eq(25)
    end
    it "should have filtered 0 records" do
      expect(num_records_filtered).to eq(0)
    end
  end

  describe_parsing_a_record '4affiliate.net' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:fqdns) { is_expected.to match_array(['4affiliate.net']) }
    end
  end

  describe_parsing_a_record '600z.com' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:fqdns) { is_expected.to match_array(['600z.com']) }
    end
  end
end


