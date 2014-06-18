require 'spec_helper'
require 'threatinator/filters/comments'

describe Threatinator::Filters::Comments do
  it_should_behave_like "a filter" do
    let(:filter) { described_class.new() }
    let(:should_filter) { [ "# Here's my comment" ] }
    let(:shouldnt_filter) { [ "I'm OK # wooo!" ] }
  end
end


