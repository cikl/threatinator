require 'spec_helper'

describe 'feeds/hosts-file_hphostspartial-domain_reputation.feed', :feed do
  let(:provider) { 'hosts-file' }
  let(:name) { 'hphostspartial_domain_reputation' }

  it_fetches_url 'http://hosts-file.net/hphosts-partial.txt'

  describe_parsing_the_file feed_data('hosts-file_hphostspartial_domainlist.txt') do
    it "should have parsed 13 records" do
      expect(num_records_parsed).to eq(13)
    end
    it "should have filtered 11 records" do
      expect(num_records_filtered).to eq(11)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record '127.0.0.1	0.cordelia8.waslittrefxwpc.eu' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:malware_host) }
      its(:fqdns) { is_expected.to match_array(['0.cordelia8.waslittrefxwpc.eu']) }
    end
  end

  describe_parsing_a_record '127.0.0.1	009.blogfoxnewsators.ru' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:malware_host) }
      its(:fqdns) { is_expected.to match_array(['009.blogfoxnewsators.ru']) }
    end
  end
end


