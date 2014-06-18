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

  context "when initialized with required fields" do
    let (:feed) do 
      described_class.new(
        :provider => provider, 
        :name => name,
        :fetcher_class => fetcher_class,
        :parser_class => parser_class,
        :parser_block => parser_block
      ) 
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


