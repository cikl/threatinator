require 'spec_helper'
require 'threatinator/plugin_registry'

describe Threatinator::PluginRegistry do
  let(:registry) { described_class.new }
  describe "#register_output" do
    it "converts the name to a symbol using #to_sym" do
      klass = Class.new(Threatinator::Output)
      key = double("somekey")
      expect(key).to receive(:to_sym).and_return(:foo)
      registry.register_output(key, klass)
    end

    it "registers the provided output class to the given name" do
      klass = Class.new(Threatinator::Output)
      registry.register_output(:foo, klass)
      expect(registry.get_output_by_name(:foo)).to be(klass)
    end

    it "returns the class that was registered" do
      klass = Class.new(Threatinator::Output)
      expect(registry.register_output(:foo, klass)).to be(klass)
    end

    it "raises AlreadyRegisteredError if the anything has already registered with the the given name" do
      klass = Class.new(Threatinator::Output)
      registry.register_output(:foo, klass)
      expect { 
        registry.register_output(:foo, klass)
      }.to raise_error(Threatinator::Exceptions::AlreadyRegisteredError)
    end

  end

  describe "#get_output_by_name" do
    it "converts the name to a symbol using #to_sym" do
      klass = Class.new(Threatinator::Output)
      registry.register_output(:foo, klass)
      key = double("somekey")
      expect(key).to receive(:to_sym).and_return(:foo)
      registry.get_output_by_name(key)
    end

    it "raises Threatinator::Exceptions::UnknownPlugin if no output is registered to the given name" do
      expect {
        registry.get_output_by_name(:foo)
      }.to raise_error(Threatinator::Exceptions::UnknownPlugin)
    end

    it "returns the class that was registered to the given name" do
      klass = Class.new(Threatinator::Output)
      registry.register_output(:foo, klass)
      expect(registry.get_output_by_name(:foo)).to be(klass)
    end
  end
end
