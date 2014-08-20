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
    it "returns itself" do
      expect(loader.load_all_plugins).to be(loader)
    end

    it "loads all plugins found in the $LOAD_PATH" do
      loader.load_all_plugins
      expect(loader.each(:test_type1).map {|*args| args }).to contain_exactly(
        [:test_type1, :plugin_a, Threatinator::Plugins::TestType1::PluginA], 
        [:test_type1, :plugin_b, Threatinator::Plugins::TestType1::PluginB])
      expect(loader.each(:test_type2).map {|*args| args }).to contain_exactly(
        [:test_type2, :plugin_c, Threatinator::Plugins::TestType2::PluginC], 
        [:test_type2, :plugin_d, Threatinator::Plugins::TestType2::PluginD])
      expect(loader.each(:test_type3).map {|*args| args }).to contain_exactly(
        [:test_type3, :plugin_e, Threatinator::Plugins::TestType3::PluginE], 
        [:test_type3, :plugin_f, Threatinator::Plugins::TestType3::PluginF])
    end
  end

  describe "#load_plugins" do
    it "returns itself" do
      expect(loader.load_plugins(:test_type1)).to be(loader)
    end

    it "loads all plugins found in the $LOAD_PATH that are of the specified type" do
      expect { |b| loader.each(:test_type1, &b) }.not_to yield_control
      expect { |b| loader.each(:test_type2, &b) }.not_to yield_control
      expect { |b| loader.each(:test_type3, &b) }.not_to yield_control

      loader.load_plugins(:test_type1)
      expect(loader.each(:test_type1).map {|*args| args }).to contain_exactly(
        [:test_type1, :plugin_a, Threatinator::Plugins::TestType1::PluginA], 
        [:test_type1, :plugin_b, Threatinator::Plugins::TestType1::PluginB])

      expect { |b| loader.each(:test_type2, &b) }.not_to yield_control
      expect { |b| loader.each(:test_type3, &b) }.not_to yield_control


      loader.load_plugins(:test_type2)
      expect(loader.each(:test_type1).map {|*args| args }).to contain_exactly(
        [:test_type1, :plugin_a, Threatinator::Plugins::TestType1::PluginA], 
        [:test_type1, :plugin_b, Threatinator::Plugins::TestType1::PluginB])
      expect(loader.each(:test_type2).map {|*args| args }).to contain_exactly(
        [:test_type2, :plugin_c, Threatinator::Plugins::TestType2::PluginC], 
        [:test_type2, :plugin_d, Threatinator::Plugins::TestType2::PluginD])
      expect { |b| loader.each(:test_type3, &b) }.not_to yield_control


      loader.load_plugins(:test_type3)
      expect(loader.each(:test_type1).map {|*args| args }).to contain_exactly(
        [:test_type1, :plugin_a, Threatinator::Plugins::TestType1::PluginA], 
        [:test_type1, :plugin_b, Threatinator::Plugins::TestType1::PluginB])
      expect(loader.each(:test_type2).map {|*args| args }).to contain_exactly(
        [:test_type2, :plugin_c, Threatinator::Plugins::TestType2::PluginC], 
        [:test_type2, :plugin_d, Threatinator::Plugins::TestType2::PluginD])
      expect(loader.each(:test_type3).map {|*args| args }).to contain_exactly(
        [:test_type3, :plugin_e, Threatinator::Plugins::TestType3::PluginE], 
        [:test_type3, :plugin_f, Threatinator::Plugins::TestType3::PluginF])
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

      expect(loader.send(:split_file_name, File.join("foobar", "threatinator", "plugins", "type", "bla", "name.rb"))).to be_nil
      expect(loader.send(:split_file_name, File.join("plugins", "type", "name.rb"))).to be_nil
      expect(loader.send(:split_file_name, File.join("type", "name.rb"))).to be_nil
      expect(loader.send(:split_file_name, "name.rb")).to be_nil

    end

    it "returns an array of the requirable path, plugin type, and plugin name" do

      file_name = File.join("foobar", "threatinator", "plugins", "type", "name.rb")
      expect(loader.send(:split_file_name, file_name)).to eq(['threatinator/plugins/type/name', 'type', 'name'])
    end

    FILE_NAME1 = File.join("threatinator", "plugins", "some_type", "some_name.rb")
    FILE_NAME2 = File.join("foo", "bar", "lib", "threatinator", "plugins", "some_type", "some_name.rb")

    shared_examples_for "simple split_file_name example" do
      it { should eq([File.join("threatinator", "plugins", "some_type", "some_name"), "some_type", "some_name"]) }
    end
    describe "the return of split_file_name('#{FILE_NAME1}')" do
      subject { loader.send(:split_file_name, FILE_NAME1) }
      include_examples "simple split_file_name example" 
    end

    describe "the return of split_file_name('#{FILE_NAME2}')" do
      subject { loader.send(:split_file_name, FILE_NAME2) }
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

  describe "#get(type, name)" do
    context "when there are no plugins for the specified type" do
      it "returns nil" do
        expect(loader.get(:test_type1, :name)).to be_nil
      end
    end

    context "when there are plugins for the specified type" do
      context "when a plugin does not exist for the specified name" do
        it "returns nil" do
          loader.load_plugins(:test_type1)
          expect(loader.get(:test_type1, :foobar)).to be_nil
        end
      end

      context "when a plugin does exist for the specified name" do
        it "returns the plugin" do
          loader.load_plugins(:test_type1)
          expect(loader.get(:test_type1, :plugin_a)).to eq(Threatinator::Plugins::TestType1::PluginA)
        end
      end
    end
  end

  describe "#each" do
    context "when there are no plugins loaded" do
      it "doesn't yield anything" do
        expect { |b|
          loader.each(&b)
        }.not_to yield_control
      end
    end

    context "when there plugins loaded" do
      it "yields the type, name, and plugin for all plugins" do
        loader.load_plugins(:test_type1)
        loader.load_plugins(:test_type2)
        loader.load_plugins(:test_type3)

        data = []
        loader.each do |type, name, plugin|
          data << [type, name, plugin]
        end
        expect(data).to contain_exactly(
          [:test_type1, :plugin_a, Threatinator::Plugins::TestType1::PluginA],
          [:test_type1, :plugin_b, Threatinator::Plugins::TestType1::PluginB],
          [:test_type2, :plugin_c, Threatinator::Plugins::TestType2::PluginC], 
          [:test_type2, :plugin_d, Threatinator::Plugins::TestType2::PluginD],
          [:test_type3, :plugin_e, Threatinator::Plugins::TestType3::PluginE], 
          [:test_type3, :plugin_f, Threatinator::Plugins::TestType3::PluginF]
        )
      end
    end
  end

  describe "#each(type)" do
    context "when there are no plugins for the specified type" do
      it "doesn't yield anything" do
        expect { |b|
          loader.each(:foobar, &b)
        }.not_to yield_control
      end
    end

    context "when there are plugins for the specified type" do
      it "yields the type, name, and plugin for each plugin of the specified type" do
        loader.load_plugins(:test_type1)
        data = []
        loader.each(:test_type1) do |type, name, plugin|
          data << [type, name, plugin]
        end
        expect(data).to contain_exactly(
          [ :test_type1, :plugin_a, Threatinator::Plugins::TestType1::PluginA],
          [ :test_type1, :plugin_b, Threatinator::Plugins::TestType1::PluginB]
        )
      end
    end
  end
end
