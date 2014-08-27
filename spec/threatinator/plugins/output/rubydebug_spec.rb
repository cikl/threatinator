require 'spec_helper'
require 'threatinator/plugins/output/rubydebug'
require 'stringio'

describe Threatinator::Plugins::Output::Rubydebug do
  let(:config) { Threatinator::Plugins::Output::Rubydebug::Config.new }

  it_should_behave_like "a file-based output plugin", :rubydebug

  describe "the output" do
    let(:output) { described_class.new(config) }
    let(:io) { StringIO.new }
    before :each do
      config.io = io
      events.each do |e|
        output.handle_event(e)
      end
    end

    let(:events) { 
      ret = []
      1.upto(10) do |i|
        ret << build(:event, feed_provider: "my_prov#{i}", 
              feed_name: "my_name#{i}", type: :scanning,
              ipv4s: ["#{i}.1.1.1","#{i}.1.1.2","#{i}.1.1.3","#{i}.1.1.4","#{i}.1.1.5"],
              fqdns: ["a#{i}.com","b#{i}.com","c#{i}.com","d#{i}.com","e#{i}.com"]
             ) 
      end
      ret
    }

    it "outputs a bunch of stuff" do
      expect(io.string.length).to be > 0
    end
  end
end

