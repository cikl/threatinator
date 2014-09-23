require 'spec_helper'
require 'threatinator/model/observables/url_collection'
require 'addressable/uri'

describe Threatinator::Model::Observables::UrlCollection do
  it_behaves_like "a model collection" do
    def generate_ten_valid_members
      ret = []
      1.upto(10) do |i|
        ret << ::Addressable::URI.parse("http://foobar#{i}.com")
      end
      ret
    end

    def generate_invalid_members
      [
        1234, 
       :foobar,
       'http://yahoo.com',
       ::Addressable::URI.parse('/foo/bar')
      ]
    end
  end

  let(:collection) { described_class.new }

  describe "#valid_member?(v)" do
    it "returns true when an absolute Addressable::URI" do
      url = Addressable::URI.parse('http://yahoo.com')
      expect(collection.valid_member?(url)).to eq(true)
    end

    it "returns false when the Addressable::URI is relative"  do
      url = Addressable::URI.parse('/foo/bar')
      expect(collection.valid_member?(url)).to eq(false)
    end

    it "returns false when not an Addressable::URI" do
      expect(collection.valid_member?('http://yahoo.com')).to eq(false)
      expect(collection.valid_member?(:foobar)).to eq(false)
      expect(collection.valid_member?(nil)).to eq(false)
    end
  end
end

