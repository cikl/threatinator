require 'spec_helper'
require 'threatinator/plugins/output/csv'
require 'stringio'

describe Threatinator::Plugins::Output::Csv do
  let(:config) { Threatinator::Plugins::Output::Csv::Config.new }
  it_should_behave_like "a file-based output plugin", :csv

  describe "the output" do
    let(:io) { StringIO.new }
    let(:output) { described_class.new(config) }

    before :each do
      config.io = io
      events.each do |e|
        output.handle_event(e)
      end
    end

    let(:lines) { io.string.lines.to_a }
    let(:events) { 
      ret = []
      1.upto(10) do |i|
        ret << build(:event, feed_provider: "my_prov#{i}", 
              feed_name: "my_name#{i}", type: :scanning,
              ipv4s: ["#{i}.1.1.1","#{i}.1.1.2","#{i}.1.1.3","#{i}.1.1.4","#{i}.1.1.5"],
              fqdns: ["a#{i}.com","b#{i}.com","c#{i}.com","d#{i}.com","e#{i}.com"],
              urls:  ["http://a#{i}.com","http://b#{i}.com","http://c#{i}.com","http://d#{i}.com","http://e#{i}.com"],
             ) 
      end
      ret
    }


    describe "the header" do
      subject { lines.first }
      it { is_expected.to eq("provider,feed_name,type,ipv4_1,ipv4_2,ipv4_3,ipv4_4,fqdn_1,fqdn_2,fqdn_3,fqdn_4,url_1,url_2,url_3,url_4\n") }
    end

    it "outputs each event, limited to the first four IPs and four fqdns" do
      line2 = lines[1]
      1.upto(10) do |i|
        expect(lines[i]).to eq("my_prov#{i},my_name#{i},scanning,#{i}.1.1.1,#{i}.1.1.2,#{i}.1.1.3,#{i}.1.1.4,a#{i}.com,b#{i}.com,c#{i}.com,d#{i}.com,http://a#{i}.com,http://b#{i}.com,http://c#{i}.com,http://d#{i}.com\n")
      end
    end
  end
end
