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

      it "queries the feed registry for the provider and name" do
        action.exec
        expect(feed_registry).to have_received(:get).with("my_provider", "my_name")
      end

      it "builds the output using config.output.build_output" do
        action.exec
        expect(config.output).to have_received(:build_output)
      end

      it "runs the feed" do
        action.exec
        expect(feed_runner).to have_received(:run)
      end

      context "when a record was missed" do
        let(:status_observer) { Threatinator::Actions::Run::StatusObserver.new }
        before :each do
          allow(Threatinator::Actions::Run::StatusObserver).to receive(:new).and_return(status_observer)
          allow(status_observer).to receive(:missed?).and_return(true)
        end

        it "logs an error message" do
          expect(action.logger).to receive(:error).with(/records were MISSED/)
          action.exec
        end
      end
    end

    context "when configured with an observer" do
      before :each do
        allow(feed_runner).to receive(:add_observer)
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

