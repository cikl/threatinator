require 'spec_helper'
require 'threatinator/model/observables/fqdn_collection'

describe Threatinator::Model::Observables::FqdnCollection do
  it_behaves_like "a model collection" do
    def generate_ten_valid_members
      ret = []
      1.upto(10) do |i|
        ret << "domain#{i}.com"
      end
      ret
    end

    def generate_invalid_members
      [1234, :foobar]
    end
  end

  let(:collection) { described_class.new }

  describe "#valid_member?(v)" do
    context "when provided a valid FQDN string" do
      it "returns true" do
        expect(collection.valid_member?("yahoo.com")).to eq(true)
      end
    end

    context "when provided an invalid FQDN string" do
      it "returns false" do
        pending "doesn't actually validate fqdns, yet"
        expect(collection.valid_member?("yahoo..com")).to eq(false)
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
