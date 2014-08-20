require 'spec_helper'
require 'threatinator/actions/run/config'
require 'threatinator/plugin_loader'
require 'fixtures/plugins/fake'

describe Threatinator::Actions::Run::Config do

  let(:plugin_loader) { Threatinator::PluginLoader.new }

  describe ".generate(plugin_loader)" do
    before :each do
      allow(Threatinator::Actions::Run::OutputConfig).to receive(:generate).and_call_original
      plugin_loader.register_plugin(:output, :plugin1, FakeOutputPlugins::Plugin1)
      plugin_loader.register_plugin(:output, :plugin2, FakeOutputPlugins::Plugin2)
      plugin_loader.register_plugin(:output, :plugin3, FakeOutputPlugins::Plugin3)
      @generated_class = described_class.generate(plugin_loader)
    end

    let(:generated_class) { @generated_class }

    it "returns a subclass of Threatinator::Config::Base" do
      expect(generated_class.superclass).to be(Threatinator::Config::Base)
    end

    it "generates a new Output config class using the plugin_loader" do
      expect(Threatinator::Actions::Run::OutputConfig).to have_received(:generate).with(plugin_loader)
    end

    describe "an instance" do
      let(:config) { generated_class.new }
      describe "#output" do
        specify "returns an instance of a subclass of Threatinator::Config::Base" do
          expect(config.output.class.superclass).to be(Threatinator::Config::Base)
        end
      end
    end
  end
end

