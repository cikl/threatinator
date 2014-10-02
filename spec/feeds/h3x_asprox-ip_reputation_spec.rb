require 'spec_helper'

describe 'feeds/h3x_asprox.feed', :feed do
  let(:provider) { 'h3x' }
  let(:name) { 'asprox' }

  it_fetches_url 'http://atrack.h3x.eu/api/asprox_all.php'

  describe_parsing_the_file feed_data('h3x_asprox.txt') do
    it "should have parsed 20 records" do
      expect(num_records_parsed).to eq(20)
    end
    it "should have filtered 0 records" do
      expect(num_records_filtered).to eq(0)
    end
    it "should have missed 0 records" do
      expect(num_records_missed).to eq(0)
    end
  end

  describe_parsing_a_record '178.79.161.146:443' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
	  its(:ipv4s) { is_expected.to eq(build(:ipv4s, values: ['178.79.161.146'])) }
    end
  end

  describe_parsing_a_record '162.218.236.73:8080' do
    it "should have parsed" do
      expect(status).to eq(:parsed)
    end
    it "should have parsed 1 event" do
      expect(events.count).to eq(1)
    end
	describe 'event 0' do
      subject { events[0] }
      its(:type) { is_expected.to be(:c2) }
	  its(:ipv4s) { is_expected.to eq(build(:ipv4s, values: ['162.218.236.73'])) }
    end
  end
end


