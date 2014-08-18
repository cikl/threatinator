require 'spec_helper'
require 'threatinator/parsers/xml/record'

describe Threatinator::Parsers::XML::Record do
  it_should_behave_like 'a record' do
    let(:data) { 
      Threatinator::Parsers::XML::Node.new('foo', text: 'bar')
    }
    let(:opts) { { } }
  end

  context "two instances with different data" do
    it_should_behave_like 'a record when compared to a differently configured record' do
      let(:data) { 
        Threatinator::Parsers::XML::Node.new('foo', text: 'bar')
      }
      let(:opts) { { } }

      let(:data2) { 
        Threatinator::Parsers::XML::Node.new('foo', text: 'bar2')
      }
      let(:opts2) { {} }
    end
  end
end


