require 'spec_helper'
require 'threatinator/feed'

describe Threatinator::Feed do
  let (:provider) { 'FakeSecureCo' }
  let (:name) { 'MaliciousDataFeed' }
  let(:fetcher_io) { double("io") }
  let(:parser_block) { lambda {}  }
  let(:filter_builders) { [] }
  let(:decoder_builders) { [] }
  let(:fetcher_builder) { lambda { FeedSpec::Fetcher.new({}) }  }
  let(:parser_builder) { lambda { FeedSpec::Parser.new({}) { } }  }

  let(:feed_opts) { 
    {
      :provider => provider, 
      :name => name,
      :parser_block => parser_block,
      :fetcher_builder => fetcher_builder,
      :parser_builder => parser_builder,
      :filter_builders => filter_builders,
      :decoder_builders => filter_builders,
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

  describe ":fetcher_builder" do
    let(:field) { :fetcher_builder} 
    include_examples "a field that is required", :fetcher_builder
    include_examples "a field with a valid value", lambda { } 
    include_examples "a field with an invalid value", Class.new
    include_examples "a field with an invalid value", 1234
    include_examples "a field with an invalid value", :asdf
    include_examples "a field with an invalid value", []
    include_examples "a field with an invalid value", {}
  end

  describe ":parser_builder" do
    let(:field) { :parser_builder } 
    include_examples "a field that is required", :parser_builder
    include_examples "a field with a valid value", lambda { } 
    include_examples "a field with an invalid value", Class.new
    include_examples "a field with an invalid value", 1234
    include_examples "a field with an invalid value", :asdf
    include_examples "a field with an invalid value", []
    include_examples "a field with an invalid value", {}
  end

  describe ":filter_builders" do
    let(:field) { :filter_builders} 
    include_examples "a field with a default", []
    include_examples "a field with a valid value", []
    include_examples "a field with a valid value", [ lambda { }  ]
    include_examples "a field that is immutable"
    include_examples "a field with an invalid value", Class.new
    include_examples "a field with an invalid value", 1234
    include_examples "a field with an invalid value", :asdf
    include_examples "a field with an invalid value", [1,2,3]
    include_examples "a field with an invalid value", {}
  end

  describe ":decoder_builders" do
    let(:field) { :decoder_builders} 
    include_examples "a field with a default", []
    include_examples "a field with a valid value", []
    include_examples "a field with a valid value", [ lambda { }  ]
    include_examples "a field that is immutable"
    include_examples "a field with an invalid value", Class.new
    include_examples "a field with an invalid value", 1234
    include_examples "a field with an invalid value", :asdf
    include_examples "a field with an invalid value", [1,2,3]
    include_examples "a field with an invalid value", {}
  end

  describe ":parser_block" do
    let(:field) { :parser_block } 
    include_examples "a field that is required", :parser_block
    include_examples "a field with a valid value", lambda {}
    include_examples "a field with an invalid value", 1234
    include_examples "a field with an invalid value", :asdf
    include_examples "a field with an invalid value", []
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

    describe "#parser_block" do
      it "should return the parser_block" do
        expect(feed.parser_block).to eq(parser_block)
      end
    end

  end
end


