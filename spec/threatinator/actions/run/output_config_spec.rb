require 'spec_helper'
require 'threatinator/actions/run/output_config'
require 'threatinator/plugin_loader'
require 'fixtures/plugins/fake'

describe Threatinator::Actions::Run::OutputConfig do
  let(:plugin_loader) { Threatinator::PluginLoader.new }

  describe ".generate(plugin_loader)" do
    before :each do
      plugin_loader.register_plugin(:output, :plugin1, FakeOutputPlugins::Plugin1)
      plugin_loader.register_plugin(:output, :plugin2, FakeOutputPlugins::Plugin2)
      plugin_loader.register_plugin(:output, :plugin3, FakeOutputPlugins::Plugin3)
    end

    let(:generated_class) { described_class.generate(plugin_loader) }
    it "returns a subclass of Threatinator::Config::Base" do
      expect(generated_class.superclass).to be(Threatinator::Config::Base)
    end

    describe "#formats" do
      it "returns an array containing all the registered output format names" do
        expect(generated_class.formats).to contain_exactly('plugin1', 'plugin2', 'plugin3')
      end
    end

    describe "#formats_str" do
      it "returns a string of the #formats sorted alphabetically" do
        expect(generated_class.formats_str).to eq('plugin1, plugin2, plugin3')
      end
    end

    describe "attributes" do
      describe ":format" do
        describe "description" do
          it "should describe the output and the available formats" do
            a = generated_class.attribute_set[:format]
            desc_proc = a.options[:description]
            ret = desc_proc.call(generated_class, a)
            expect(ret).to eq('Output format (plugin1, plugin2, plugin3)')
          end
        end
      end
    end

    describe "an instance" do
      let(:config) { generated_class.new }
      specify "has an attribute for each plugin name that is an instance of that plugin's config" do
        expect(config.plugin1).to be_a(FakeOutputPlugins::Plugin1::Config)
        expect(config.plugin1).to respond_to(:foo)
        expect(config.plugin2).to be_a(FakeOutputPlugins::Plugin2::Config)
        expect(config.plugin2).to respond_to(:bar)
        expect(config.plugin3).to be_a(FakeOutputPlugins::Plugin3::Config)
        expect(config.plugin3).to respond_to(:woof)
      end

      describe "#build_output" do
        it "raises UnknownPlugin when no plugin is found for the value of #format" do
          config.format = :asdf
          expect {
            config.build_output
          }.to raise_error(Threatinator::Exceptions::UnknownPlugin)
        end

        it "raises CouldNotFindOutputConfigError if there is no config for the #format" do
          config.format = :plugin1
          config.plugin1 = nil
          expect {
            config.build_output
          }.to raise_error(Threatinator::Exceptions::CouldNotFindOutputConfigError)
        end

        context "when #format is associated with a reigstered plugin" do
          it "initializes the output plugin with the plugin's config" do
            config.format = :plugin2
            expect(FakeOutputPlugins::Plugin2).to receive(:new).with(config.plugin2)
            config.build_output
          end

          it "returns an instance of the output plugin" do
            config.format = :plugin3
            expect(config.build_output).to be_a(FakeOutputPlugins::Plugin3)
          end
        end
      end
    end
  end
end

