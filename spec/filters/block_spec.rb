require 'spec_helper'
require 'threatinator/filters/block'

describe Threatinator::Filters::Block do
  it_should_behave_like "a filter" do
    let(:filter_block) {
      lambda do |line|
        line =~ /^FILTERME$/
      end
    }
    let(:filter) { described_class.new(filter_block) }
    let(:should_filter) { [ "FILTERME" ] }
    let(:shouldnt_filter) { [ "I'm OK!" ] }
  end
end
