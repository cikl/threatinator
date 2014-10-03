require 'spec_helper'

describe 'feeds/openphish-url_reputation.feed', :feed do
  let(:provider) { 'openphish' }
  let(:name) { 'url_reputation' }

  it_fetches_url 'http://openphish.com/feed.txt'

  describe_parsing_the_file feed_data('openphish-url-reputation.txt') do
    it "should have parsed 15 records" do
      expect(num_records_parsed).to eq(15)
    end
    it "should have filtered 1 records" do
      expect(num_records_filtered).to eq(1)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record 'http://107.190.137.202/~akshat/images/fr/webscr.confirmer.secure.connexion.mpp.information.compte.webapps.home/8fa5aed41992b676cf5305ee5c3d4e1e/login.php' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:malware_host) }
	  its(:urls) { is_expected.to eq(build(:urls, values: ['http://107.190.137.202/~akshat/images/fr/webscr.confirmer.secure.connexion.mpp.information.compte.webapps.home/8fa5aed41992b676cf5305ee5c3d4e1e/login.php'])) }
    end
  end

  describe_parsing_a_record 'http://haraiscompany.com/images/zpsiios/5g60jpjhifajb8rrvx1ixr/?jsp=main' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:malware_host) }
	  its(:urls) { is_expected.to eq(build(:urls, values: ['http://haraiscompany.com/images/zpsiios/5g60jpjhifajb8rrvx1ixr/?jsp=main'])) }
    end
  end
end


