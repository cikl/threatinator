require 'spec_helper'
require 'threatinator/registry'

describe Threatinator::Registry do
  let(:registry) { described_class.new }
  let(:ten_things) { {
    a: Object.new,
    b: Object.new,
    c: Object.new,
    d: Object.new,
    e: Object.new,
    f: Object.new,
    g: Object.new,
    h: Object.new,
    i: Object.new,
    j: Object.new
  } }

  describe "#clear" do
    it "should remove all existing registrations" do
      expect(registry.count).to eq(0)
      registry.register(:foo, 123)
      registry.register(:bar, 456)
      expect(registry.count).to eq(2)
      registry.clear
      expect(registry.count).to eq(0)
    end
  end

  describe "#keys" do
    it "returns an array containing all of the keys" do
      expect(registry.keys).to eq([])
      registry.register(:foo, Object.new)
      registry.register(:bar, Object.new)
      registry.register(:woof, Object.new)
      expect(registry.keys).to contain_exactly(:foo, :bar, :woof)
    end
  end

  describe "#register" do
    it "should register the provided object to the given key" do
      obj = Object.new
      registry.register(:foo, obj)
      expect(registry.get(:foo)).to be(obj)
    end

    it "should return the object that was registered" do
      obj = Object.new
      expect(registry.register(:foo, obj)).to be(obj)
    end

    it "should raise a AlreadyRegisteredError if something is already registered with the the given key" do
      obj = Object.new
      registry.register(:foo, obj)
      expect { 
        registry.register(:foo, obj)
      }.to raise_error(Threatinator::Exceptions::AlreadyRegisteredError)
    end
  end

  describe "#each" do
    it "should enumerate through each key and registered object" do
      ten_things.each_pair do |i, thing|
        registry.register(i, thing)
      end
      found_objects = []
      registry.each do |key, obj|
        found_objects << [ key, obj ]
      end
      expect(found_objects).to match_array(ten_things.to_a)
    end
  end

  describe "#count" do
    it "should return the number of objects contained within the registry" do
      expect(registry.count).to eq(0)
      ten_things.each_pair do |i, thing|
        registry.register(i, thing)
      end
      expect(registry.count).to eq(10)
    end
  end

  describe "#get" do
    it "should return nil if key isn't registered" do
      expect(registry.get(:foo)).to be_nil
    end

    it "should return the correct feed for the key" do
      ten_things.each_pair { |i, o| registry.register(i, o) }
      obj = Object.new
      registry.register(:foo, obj)
      expect(registry.get(:foo)).to be(obj)
    end
  end
end

