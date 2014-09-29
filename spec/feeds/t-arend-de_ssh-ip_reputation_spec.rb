require 'spec_helper'

describe 'feeds/t-arend-de_ssh-ip_reputation.feed', :feed do
  let(:provider) { 't-arend-de' }
  let(:name) { 'ssh_ip_reputation' }

  it_fetches_url 'http://www.t-arend.de/linux/badguys.txt'

  describe_parsing_the_file feed_data('t-arend-de_ssh_iplist.txt') do
    it "should have parsed 14 records" do
      expect(num_records_parsed).to eq(14)
    end
    it "should have filtered 3 records" do
      expect(num_records_filtered).to eq(3)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record 'sshd: 121.15.167.243' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['121.15.167.243'])) }
    end
  end

  describe_parsing_a_record 'sshd: 122.224.128.222' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['122.224.128.222'])) }
    end
  end
end


