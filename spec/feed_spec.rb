require 'spec_helper'
require 'threatinator/feed'

describe Threatinator::Feed do
  let (:provider) { 'FakeSecureCo' }
  let (:name) { 'MaliciousDataFeed' }
  let(:fetcher_io) { double("io") }
  let(:fetcher_class) { FeedSpec::Fetcher }
  let(:fetcher_opts) { { :io => fetcher_io } }
  let(:parser_class) { FeedSpec::Parser }
  let(:parser_opts) { {} }
  let(:parser_block) { lambda {}  }

  let(:feed_opts) { 
    {
      :provider => provider, 
      :name => name,
      :fetcher_class => fetcher_class,
      :parser_class => parser_class,
      :parser_block => parser_block
    }
  }

  shared_examples_for "a field with an invalid value" do |value|
    it "should raise InvalidAttributeError if it is a #{value.class}" do
      expect { 
        described_class.new(feed_opts.merge(field => value)) 
      }.to raise_error(Threatinator::Exceptions::InvalidAttributeError)
    end
  end

  shared_examples_for "a field with a valid value" do |value|
    it "should not raise any errors when set to a #{value.class}" do
      expect { 
        described_class.new(feed_opts.merge(field => value)) 
      }.not_to raise_error
    end
  end

  shared_examples_for "a field that is required" do
    it "is required" do
      feed_opts.delete(field)
      expect { described_class.new(feed_opts) }.to raise_error(Threatinator::Exceptions::InvalidAttributeError)
    end
  end

  shared_examples_for "a field with a default" do |value|
    it "should default to #{value.inspect}" do
      feed_opts.delete(field)
      feed = described_class.new(feed_opts)
      expect(feed.send(field)).to eq(value)
    end
  end

  shared_examples_for "a field that is immutable" do
    it "should be immutable" do
      feed = described_class.new(feed_opts) 
      expect(feed.send(field)).not_to be(feed.send(field))
    end
  end

  describe ":provider" do
    let(:field) { :provider } 
    include_examples "a field that is required"
    include_examples "a field that is immutable"
    include_examples "a field with a valid value", "asdf"
    include_examples "a field with an invalid value", 1234
    include_examples "a field with an invalid value", :asdf
    include_examples "a field with an invalid value", []
    include_examples "a field with an invalid value", {}
  end

  describe ":name" do
    let(:field) { :name } 
    include_examples "a field that is required", :name
    include_examples "a field that is immutable"
    include_examples "a field with a valid value", "asdf"
    include_examples "a field with an invalid value", 1234
    include_examples "a field with an invalid value", :asdf
    include_examples "a field with an invalid value", []
    include_examples "a field with an invalid value", {}
  end

  describe ":fetcher_class" do
    let(:field) { :fetcher_class } 
    include_examples "a field that is required", :fetcher_class
    include_examples "a field with a valid value", FeedSpec::Fetcher
    include_examples "a field with an invalid value", 1234
    include_examples "a field with an invalid value", :asdf
    include_examples "a field with an invalid value", []
    include_examples "a field with an invalid value", {}
  end
  describe ":fetcher_opts" do
    let(:field) { :fetcher_opts } 
    include_examples "a field with a default", {}
    include_examples "a field that is immutable"
    include_examples "a field with a valid value", {some: "data"}
    include_examples "a field with an invalid value", 1234
    include_examples "a field with an invalid value", :asdf
    include_examples "a field with an invalid value", []
  end

  describe ":parser_class" do
    let(:field) { :parser_class } 
    include_examples "a field that is required", :parser_class
    include_examples "a field with a valid value", FeedSpec::Parser
    include_examples "a field with an invalid value", 1234
    include_examples "a field with an invalid value", :asdf
    include_examples "a field with an invalid value", []
    include_examples "a field with an invalid value", {}
  end
  describe ":parser_opts" do
    let(:field) { :parser_opts } 
    include_examples "a field with a default", {}
    include_examples "a field that is immutable"
    include_examples "a field with a valid value", {some: "data"}
    include_examples "a field with an invalid value", 1234
    include_examples "a field with an invalid value", :asdf
    include_examples "a field with an invalid value", []
  end

  describe ":parser_block" do
    let(:field) { :parser_block } 
    include_examples "a field that is required", :parser_block
    include_examples "a field with a valid value", lambda {}
    include_examples "a field with an invalid value", 1234
    include_examples "a field with an invalid value", :asdf
    include_examples "a field with an invalid value", []
  end

  describe ":filters" do
    let(:field) { :filters } 
    include_examples "a field with a default", []
    include_examples "a field that is immutable"
    include_examples "a field with a valid value", []
    include_examples "a field with an invalid value", 1234
    include_examples "a field with an invalid value", :asdf
    include_examples "a field with an invalid value", {}
  end

  context "when initialized with required fields" do
    let (:feed) do 
      described_class.new(feed_opts) 
    end

    describe "#name" do
      it "should return the name" do
        expect(feed.name).to eq(name)
      end
    end

    describe "#provider" do
      it "should return the provider" do
        expect(feed.provider).to eq(provider)
      end
    end

    describe "#fetcher_class" do
      it "should return the fetcher_class" do
        expect(feed.fetcher_class).to eq(fetcher_class)
      end
    end

    describe "#fetcher_opts" do
      it "should return the default {}" do
        expect(feed.fetcher_opts).to eq({})
      end
    end

    describe "#parser_class" do
      it "should return the parser_class" do
        expect(feed.parser_class).to eq(parser_class)
      end
    end

    describe "#parser_block" do
      it "should return the parser_block" do
        expect(feed.parser_block).to eq(parser_block)
      end
    end

    describe "#parser_opts" do
      it "should return the default {}" do
        expect(feed.parser_opts).to eq({})
      end
    end

    describe "#filters" do
      it "should return the default []" do
        expect(feed.filters).to eq([])
      end
    end

  end
end


