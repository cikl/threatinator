require 'spec_helper'
require 'threatinator/io_wrappers/rot13'

describe Threatinator::IOWrappers::Rot13 do
  it_should_behave_like "an iowrapper" do
    let(:input_data) { "Hfrarg vf Fb y33g!" }

    let(:expected_data) { "Usenet is So l33t!" }
  end
end



