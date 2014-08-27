require 'spec_helper'
require 'threatinator/plugins/output/null'
require 'stringio'

describe Threatinator::Plugins::Output::Null do
  let(:config) { Threatinator::Plugins::Output::Null::Config.new }
  it_should_behave_like "an output plugin", :null

  describe "#handle_event" do
    let(:output) { described_class.new(config) }
    it "does not call any methods on the event" do
      event = double("event")
      output.handle_event(event)
    end
  end
end

