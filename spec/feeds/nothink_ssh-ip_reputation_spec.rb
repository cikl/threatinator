require 'spec_helper'

describe 'feeds/nothink_ssh-ip_reputation.feed', :feed do
  let(:provider) { 'nothink' }
  let(:name) { 'ssh_ip_reputation' }

  it_fetches_url 'http://www.nothink.org/blacklist/blacklist_ssh_day.txt'

  describe_parsing_the_file feed_data('nothink_ssh_iplist.txt') do
    it "should have parsed 7 records" do
      expect(num_records_parsed).to eq(7)
    end
    it "should have filtered 3 records" do
      expect(num_records_filtered).to eq(3)
    end
  end

  describe_parsing_a_record '36.39.246.121' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['36.39.246.121'])) }
    end
  end

  describe_parsing_a_record '94.32.71.168' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['94.32.71.168'])) }
    end
  end
end


