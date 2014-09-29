require 'spec_helper'

describe 'feeds/arbor_ssh-ip_reputation.feed', :feed do
  let(:provider) { 'arbor' }
  let(:name) { 'ssh_ip_reputation' }

  it_fetches_url 'http://atlas-public.ec2.arbor.net/public/ssh_attackers'

  describe_parsing_the_file feed_data('arbor_ssh.txt') do
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

  describe_parsing_a_record '190.255.48.99' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['190.255.48.99'])) }
    end
  end

  describe_parsing_a_record '184.172.196.132' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:scanning) }
      its(:ipv4s) { is_expected.to  eq(build(:ipv4s, values: ['184.172.196.132'])) }
    end
  end
end


