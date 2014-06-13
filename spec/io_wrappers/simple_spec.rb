require 'spec_helper'
require 'threatinator/io_wrappers/simple'

describe Threatinator::IOWrappers::Simple do
  it_should_behave_like "an iowrapper" do
    let(:input_data)    { "here's some data" }
    let(:expected_data) { input_data }
  end
end
