require 'spec_helper'
require 'threatinator/json_record'

describe Threatinator::JSONRecord do
  it_should_behave_like 'a record' do
    let(:data) { {"some" => "data"} }
    let(:opts) { { } }
  end

  context "two instances with different data" do
    it_should_behave_like 'a record when compared to a differently configured record' do
      let(:data) { {"some" => "data"} }
      let(:opts) { { } }

      let(:data2) { {"some_other" => "data"} }
      let(:opts2) { {} }
    end
  end

  context "two instances with the same data but a different :key" do
    it_should_behave_like 'a record when compared to a differently configured record' do
      let(:data) { {"some" => "data"} }
      let(:opts) { { key: "foo" } }

      let(:data2) { {"some" => "data"} }
      let(:opts2) { { key: "bar" } }
    end
  end
end

