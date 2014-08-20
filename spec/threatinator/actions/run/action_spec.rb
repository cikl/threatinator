require 'spec_helper'
require 'threatinator/actions/run/action'
require 'threatinator/actions/run/config'
require 'threatinator/plugin_loader'

describe Threatinator::Actions::Run::Action do
  let(:feed_registry) { build(:feed_registry) }
  let(:feed_runner) { double('feed runner') }
  let(:plugin_loader) { Threatinator::PluginLoader.new }
  let(:config_class) { Threatinator::Actions::Run::Config.generate(plugin_loader) }
  let(:config) { config_class.new }
  let(:action) { described_class.new(feed_registry, config) }
  let(:feed) { build(:feed, provider: "my_provider", name: "my_name") }

  before :each do
    feed_registry.register(feed)
  end

  context "when configured with feed provider and name that exists within the registry" do
    let(:output) { double('mock output') }
    let(:observer) { double('observer') }
    before :each do
      config.feed_provider = "my_provider"
      config.feed_name = "my_name"

      allow(feed_registry).to receive(:get).and_call_original
      allow(config.output).to receive(:build_output).and_return(output)
      allow(Threatinator::FeedRunner).to receive(:new).and_return(feed_runner)
      allow(feed_runner).to receive(:run)
      allow(feed_runner).to receive(:add_observer)
    end

    describe "#exec" do
      before :each do
        @ret = action.exec
      end

      it "queries the feed registry for the provider and name" do
        expect(feed_registry).to have_received(:get).with("my_provider", "my_name")
      end

      it "builds the output using config.output.build_output" do
        expect(config.output).to have_received(:build_output)
      end

      it "runs the feed" do
        expect(feed_runner).to have_received(:run)
      end
    end

    context "when no observer is configured" do
      before :each do
        config.observers = [ ]
      end
      it "does not add any observers to the feed runner" do
        expect(feed_runner).not_to receive(:add_observer)
        action.exec
      end
    end

    context "when configured with an observer" do
      before :each do
        config.observers = [ observer ]
      end

      describe "#exec" do
        it "adds the observer to FeedRunner" do
          expect(feed_runner).to receive(:add_observer).with(observer)
          action.exec
        end
      end
    end
  end

  context "when the registry does not contain the configured feed_provider or feed_name" do
    before :each do
      config.feed_provider = "unknown_provider"
      config.feed_name = "unknown_feed_name"
    end
    describe "#exec" do
      it "raises Threatinator::Exceptions::UnknownFeed" do
        expect {
          action.exec
        }.to raise_error(Threatinator::Exceptions::UnknownFeed) 
      end
    end
  end
end

