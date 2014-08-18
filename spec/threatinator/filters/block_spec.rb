require 'spec_helper'
require 'threatinator/record'
require 'threatinator/filters/block'

describe Threatinator::Filters::Block do
  it_should_behave_like "a filter" do
    let(:filter_block) {
      lambda do |record|
        record.data =~ /^FILTERME$/
      end
    }
    let(:filter) { described_class.new(filter_block) }
    let(:should_filter) { Threatinator::Record.new("FILTERME") }
    let(:shouldnt_filter) { Threatinator::Record.new("I'm OK!") }
  end
end
