require 'spec_helper'
require 'threatinator/plugin_loader'

shared_context "good test plugins" do
  before :all do
    @good_plugin_path = PLUGIN_FIXTURES.join("good").to_s
    $:.unshift @good_plugin_path
  end

  after :all do
    $:.delete_if {|x| x == @good_plugin_path}
  end
end

shared_context "bad test plugins" do
  before :all do
    @bad_plugin_path = PLUGIN_FIXTURES.join("bad").to_s
    $:.unshift @bad_plugin_path
  end

  after :all do
    $:.delete_if {|x| x == @bad_plugin_path}
  end
end

describe Threatinator::PluginLoader do
  include_context "good test plugins"

  let(:loader) { described_class.new }

  describe "#load_all_plugins" do
    it "loads all plugins found in the $LOAD_PATH" do
      loader.load_all_plugins
      expect(loader[:test_type1]).to eq({plugin_a: Threatinator::Plugins::TestType1::PluginA, plugin_b: Threatinator::Plugins::TestType1::PluginB})
      expect(loader[:test_type2]).to eq({plugin_c: Threatinator::Plugins::TestType2::PluginC, plugin_d: Threatinator::Plugins::TestType2::PluginD})
      expect(loader[:test_type3]).to eq({plugin_e: Threatinator::Plugins::TestType3::PluginE, plugin_f: Threatinator::Plugins::TestType3::PluginF})
    end
  end

  describe "#load_plugins" do
    it "loads all plugins found in the $LOAD_PATH that are of the specified type" do
      expect(loader[:test_type1]).to eq({})
      expect(loader[:test_type2]).to eq({})
      expect(loader[:test_type3]).to eq({})

      loader.load_plugins(:test_type1)
      expect(loader[:test_type1]).to eq({plugin_a: Threatinator::Plugins::TestType1::PluginA, plugin_b: Threatinator::Plugins::TestType1::PluginB})
      expect(loader[:test_type2]).to eq({})
      expect(loader[:test_type3]).to eq({})


      loader.load_plugins(:test_type2)
      expect(loader[:test_type1]).to eq({plugin_a: Threatinator::Plugins::TestType1::PluginA, plugin_b: Threatinator::Plugins::TestType1::PluginB})
      expect(loader[:test_type2]).to eq({plugin_c: Threatinator::Plugins::TestType2::PluginC, plugin_d: Threatinator::Plugins::TestType2::PluginD})
      expect(loader[:test_type3]).to eq({})


      loader.load_plugins(:test_type3)
      expect(loader[:test_type1]).to eq({plugin_a: Threatinator::Plugins::TestType1::PluginA, plugin_b: Threatinator::Plugins::TestType1::PluginB})
      expect(loader[:test_type2]).to eq({plugin_c: Threatinator::Plugins::TestType2::PluginC, plugin_d: Threatinator::Plugins::TestType2::PluginD})

      expect(loader[:test_type3]).to eq({plugin_e: Threatinator::Plugins::TestType3::PluginE, plugin_f: Threatinator::Plugins::TestType3::PluginF})
    end

    context "when loading a plugin raises an exception" do
      include_context "bad test plugins"
      it "raises that error upward" do
        expect {
          loader.load_plugins(:test_error1)
        }.to raise_error()
      end
    end

    context "when a plugin class cannot be found" do
      include_context "bad test plugins"
      it "raises a PluginLoadError" do
        expect {
          loader.load_plugins(:test_missing1)
        }.to raise_error(Threatinator::Exceptions::PluginLoadError)
      end
    end
  end

  describe "#split_file_name" do
    it "returns nil if the file name is not formed like 'threatinator/plugins/<type>/<name>.rb'" do

      expect(loader.split_file_name(File.join("foobar", "threatinator", "plugins", "type", "bla", "name.rb"))).to be_nil
      expect(loader.split_file_name(File.join("plugins", "type", "name.rb"))).to be_nil
      expect(loader.split_file_name(File.join("type", "name.rb"))).to be_nil
      expect(loader.split_file_name("name.rb")).to be_nil

    end

    it "returns an array of the requirable path, plugin type, and plugin name" do

      file_name = File.join("foobar", "threatinator", "plugins", "type", "name.rb")
      expect(loader.split_file_name(file_name)).to eq(['threatinator/plugins/type/name', 'type', 'name'])
    end

    FILE_NAME1 = File.join("threatinator", "plugins", "some_type", "some_name.rb")
    FILE_NAME2 = File.join("foo", "bar", "lib", "threatinator", "plugins", "some_type", "some_name.rb")

    shared_examples_for "simple split_file_name example" do
      it { should eq([File.join("threatinator", "plugins", "some_type", "some_name"), "some_type", "some_name"]) }
    end
    describe "the return of split_file_name('#{FILE_NAME1}')" do
      subject { loader.split_file_name(FILE_NAME1) }
      include_examples "simple split_file_name example" 
    end

    describe "the return of split_file_name('#{FILE_NAME2}')" do
      subject { loader.split_file_name(FILE_NAME2) }
      include_examples "simple split_file_name example" 
    end
  end

  describe "#types" do
    context "when no plugins have been loaded" do
      it "returns an empty array" do
        expect(loader.types).to eq([])
      end
    end

    context "when some plugins have been loaded" do
      it "returns an array of type names (in symbol form)" do
        loader.load_plugins(:test_type1)
        loader.load_plugins(:test_type2)
        loader.load_plugins(:test_type3)
        expect(loader.types).to match_array([:test_type1, :test_type2, :test_type3])
      end
    end
  end

  describe "[]" do
    context "when there are no plugins for the specified type" do
      it "returns an empty hash" do
        expect(loader[:foobar]).to eq({})
      end
    end

    context "when there are plugins for the specified type" do
      it "returns a hash containing the names and classes of plugins" do
        loader.load_plugins(:test_type1)
        expect(loader[:test_type1]).to eq({plugin_a: Threatinator::Plugins::TestType1::PluginA, plugin_b: Threatinator::Plugins::TestType1::PluginB})
      end
    end
  end
end
