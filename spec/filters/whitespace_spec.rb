require 'spec_helper'
require 'threatinator/record'
require 'threatinator/filters/whitespace'

describe Threatinator::Filters::Whitespace do
  it_should_behave_like "a filter" do
    let(:filter) { described_class.new() }
    let(:should_filter) { Threatinator::Record.new("    ") }
    let(:shouldnt_filter) { Threatinator::Record.new("    I'm OK!") }
  end
end

