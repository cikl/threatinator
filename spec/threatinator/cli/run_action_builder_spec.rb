require 'spec_helper'
require 'fileutils'
require 'threatinator/cli/run_action_builder'
require 'threatinator/plugin_loader'

describe Threatinator::CLI::RunActionBuilder do
  describe 'an instance' do
    let(:plugin_loader) { Threatinator::PluginLoader.new }
    let(:config_class) { Threatinator::Actions::Run::Config.generate(plugin_loader) }
    let(:config_hash) { { 'run' => {} } }
    let(:extra_args) { [] }
    let(:builder) { described_class.new(config_hash, extra_args, config_class) }

    it_behaves_like "an action builder"

    describe "#config" do
      let(:config) { builder.config }
      it "returns an instance of config_class" do
        expect(config).to be_a(config_class)
      end

      describe "config_hash['run']['coverage_output']" do
        context "when nil" do
          before :each do
            config_hash['run'].delete('coverage_output')
          end

          it "sets config.observers to []" do
            config = builder.config
            expect(config.observers).to contain_exactly()
          end
        end

        context "when set to a string" do
          let(:coverage_proc) { lambda { } }
          before :each do
            config_hash['run']['coverage_output'] = "asdf"
          end
          it "initializes a CoverageObserver with the string" do
            expect(Threatinator::Actions::Run::CoverageObserver).to receive(:new).with('asdf')
            builder.config
          end
          it "sets config.observers an array consisting of the CoverageObserver" do
            observer = double('observer')
            expect(Threatinator::Actions::Run::CoverageObserver).to receive(:new).and_return(observer)

            config = builder.config
            expect(config.observers).to contain_exactly(observer)
          end
        end
      end

      context "config_hash['run']['feed_provider']" do
        context "when nil" do
          before :each do
            config_hash['run'].delete('feed_provider')
          end
          context "and there are no extra arguments" do
            specify "#feed_provider is nil" do
              expect(config.feed_provider).to be_nil
            end
          end

          context "and there is at least one extra argument" do
            before :each do
              extra_args << "arg1"
              extra_args << "arg2"
              extra_args << "arg3"
            end
            specify "#feed_provider is the first extra argument" do
              expect(config.feed_provider).to eq("arg1")
            end
          end
        end
      end

      context "config_hash['run']['feed_name']" do
        context "when nil" do
          before :each do
            config_hash['run'].delete('feed_name')
          end
          context "and there are no extra arguments" do
            specify "#feed_name is nil" do
              expect(config.feed_name).to be_nil
            end
          end

          context "and there are extra arguments" do
            before :each do
              extra_args << "arg1"
              extra_args << "arg2"
              extra_args << "arg3"
            end

            specify "#feed_name is the first extra argument if feed_provider was configured" do
              config_hash['run']['feed_provider'] = "foo"
              expect(config.feed_name).to eq("arg1")
            end

            specify "#feed_name is the second extra argument if feed_provider was not configured" do
              config_hash['run'].delete('feed_provider')
              expect(config.feed_name).to eq("arg2")
            end
          end
        end
      end
    end

    describe "#build" do
      let(:action) { double('action') }
      let(:config) { double('config') }
      let(:feed_registry) { double('feed registry') }
      before :each do
        allow(Threatinator::Actions::Run::Action).to receive(:new).and_return(action)
        allow(builder).to receive(:config).and_return(config)
        allow(builder).to receive(:feed_registry).and_return(feed_registry)
      end

      let(:result) { builder.build }

      it "builds an instance of Threatinator::Actions::Run::Action using #feed_registry and #config" do
        expect(Threatinator::Actions::Run::Action).to receive(:new).with(feed_registry, config)
        builder.build
      end

      it "returns the instance of the action" do
        expect(builder.build).to be(action)
      end

    end
  end
end

