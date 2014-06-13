require 'spec_helper'
require 'threatinator/io_wrappers/downcase'

describe Threatinator::IOWrappers::Downcase do
  it_should_behave_like "an iowrapper" do
    let(:input_data) { "ThiS is! My TeXT!" }

    let(:expected_data) { "this is! my text!" }
  end
end


