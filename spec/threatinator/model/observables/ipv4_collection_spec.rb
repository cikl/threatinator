require 'spec_helper'
require 'threatinator/model/observables/ipv4_collection'
require 'threatinator/model/observables/ipv4'

describe Threatinator::Model::Observables::Ipv4Collection do
  it_behaves_like "a model collection" do
    def generate_ten_valid_members
      ret = []
      1.upto(10) do |i|
        ret << build(:ipv4, ipv4: "1.2.3.#{i}")
      end
      ret
    end

    def generate_invalid_members
      [1234, :foobar]
    end
  end

  let(:collection) { described_class.new }

  describe "#valid_member?(v)" do
    context "when provided an Ipv4 observable" do
      it "returns true" do
        ipv4 = build(:ipv4, ipv4: "1.2.3.4")
        expect(collection.valid_member?(ipv4)).to eq(true)
      end
    end

    context "when provided something other than an Ipv4 observable" do
      it "returns false" do
        expect(collection.valid_member?("1.2.3.257")).to eq(false)
      end
    end
  end
end
