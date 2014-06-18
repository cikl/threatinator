require 'spec_helper'
require 'threatinator/filters/whitespace'

describe Threatinator::Filters::Whitespace do
  it_should_behave_like "a filter" do
    let(:filter) { described_class.new() }
    let(:should_filter) { [ "    " ] }
    let(:shouldnt_filter) { [ "    I'm OK!" ] }
  end
end

