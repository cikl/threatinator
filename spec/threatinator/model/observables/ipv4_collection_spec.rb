require 'spec_helper'
require 'threatinator/model/observables/ipv4_collection'

describe Threatinator::Model::Observables::Ipv4Collection do
  it_behaves_like "a model collection" do
    def generate_ten_valid_members
      ret = []
      1.upto(10) do |i|
        ret << "1.2.3.#{i}"
      end
      ret
    end

    def generate_invalid_members
      [1234, :foobar]
    end
  end

  let(:collection) { described_class.new }

  describe "#valid_member?(v)" do
    context "when provided a valid ipv4 string" do
      it "returns true" do
        expect(collection.valid_member?("1.2.3.4")).to eq(true)
      end
    end

    context "when provided an invalid ipv4 string" do
      it "returns false" do
        pending "doesn't actually validate that the strings are IPv4s, yet"
        expect(collection.valid_member?("1.2.3.257")).to eq(false)
      end
    end

    context "when provided something other than a string" do
      it "returns false" do
        expect(collection.valid_member?(:asdf)).to eq(false)
        expect(collection.valid_member?(1234)).to eq(false)
      end
    end
  end
end
