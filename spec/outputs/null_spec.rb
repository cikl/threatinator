require 'spec_helper'
require 'threatinator/outputs/null'
require 'stringio'

describe Threatinator::Outputs::Null do
  it_should_behave_like "an output plugin", :null do
    let(:output) { described_class.new() }
  end

  describe "#handle_event" do
    let(:output) { described_class.new() }
    it "does not call any methods on the event" do
      event = double("event")
      output.handle_event(event)
    end
  end
end

