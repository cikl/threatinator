require 'spec_helper'
require 'threatinator/config/feed_search'

describe Threatinator::Config::FeedSearch do
  describe "#path" do
    context "when :path not specified" do
      it "returns an empty array" do
        x = described_class.new
        expect(x.path).to eq([])
      end
    end
    context "when :path is an array of strings" do
      it "returns the array of strings" do
        x = described_class.new(path: ['foo', 'bar'])
        expect(x.path).to eq(['foo', 'bar'])
      end
    end
  end

  describe "#exclude_default" do
    context "when :exclude_default is not specified" do
      it "returns false" do
        expect(described_class.new.exclude_default).to eq(false)
      end
    end

    context "when :exclude_default is set to true" do
      it "returns true" do
        x = described_class.new(exclude_default: true)
        expect(x.exclude_default).to eq(true)
      end
    end

    context "when :exclude_default is set to false" do
      it "returns false" do
        x = described_class.new(exclude_default: false)
        expect(x.exclude_default).to eq(false)
      end
    end
  end

  describe "#search_path" do
    context "when neither :path nor :exclude_default are supplied" do
      it "returns an array containing the default search path" do
        x = described_class.new
        expect(x.search_path).to eq([described_class::DEFAULT_FEED_PATH])
      end
    end

    context "when :path is an array of paths" do
      let(:paths) { ["foo", "bar"] }
      let(:config) { described_class.new(path: paths) }
      specify "the first search paths are those specified by :path" do
        expect(config.search_path[0..1]).to eq(['foo', 'bar'])
      end

      context "when :exclude_default is not specified" do
        specify "the default search path is appended" do
          expect(config.search_path[-1]).to eq(described_class::DEFAULT_FEED_PATH)
        end
      end
      context "when :exclude_default is false" do
        let(:config) { described_class.new(path: paths, exclude_default: false) }
        specify "the default search path is appended" do
          expect(config.search_path[-1]).to eq(described_class::DEFAULT_FEED_PATH)
        end
      end
      context "when :exclude_default is true" do
        let(:config) { described_class.new(path: paths, exclude_default: true) }
        specify "the default search path is not appended" do
          expect(config.search_path[-1]).not_to eq(described_class::DEFAULT_FEED_PATH)
        end
      end
    end
  end
end
