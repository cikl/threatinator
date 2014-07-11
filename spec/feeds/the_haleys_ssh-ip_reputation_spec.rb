require 'spec_helper'

describe 'feeds/the_haleys_ssh-ip_reputation.feed', :feed do
  let(:provider) { 'the_haleys' }
  let(:name) { 'ssh_ip_reputation' }

  it_fetches_url 'http://charles.the-haleys.org/ssh_dico_attack_hdeny_format.php/hostsdeny.txt'

  describe_parsing_the_file feed_data('the_haleys_ssh_iplist.txt') do
    it "should have parsed 11 records" do
      expect(num_records_parsed).to eq(11)
    end
    it "should have filtered 1 records" do
      expect(num_records_filtered).to eq(1)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record 'ALL : 1.30.20.146' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to match_array(['1.30.20.146']) }
    end
  end

  describe_parsing_a_record 'ALL : 1.93.25.234' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to match_array(['1.93.25.234']) }
    end
  end
end


