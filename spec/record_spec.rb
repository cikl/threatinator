require 'spec_helper'
require 'threatinator/record'

describe Threatinator::Record do
  it_should_behave_like 'a record' do
    let(:data) { "asdf" }
    let(:opts) { { } }
  end
  context "two instances with different data" do
    it_should_behave_like 'a record when compared to a differently configured record' do
      let(:data) { "foo" }
      let(:opts) { { } }

      let(:data2) { "bar" }
      let(:opts2) { {} }
    end
  end

end
