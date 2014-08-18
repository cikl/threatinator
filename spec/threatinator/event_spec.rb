require 'spec_helper'
require 'threatinator/event'

describe Threatinator::Event do
  describe "#type" do
    it "should default to nil"
    it "should return the value if set"
  end

  describe "#type=" do
    Threatinator::Event::VALID_TYPES.each do |type|
      it "should be possible to set to #{type.inspect}"
    end
    it "should raise an InvalidAttributeError if set to something other than a symbol"
  end

  describe "#ipv4s" do
    it "should return an array"
  end

  describe "#fqdns" do
    it "should return an array"
  end

  describe "#add_ipv4" do
  end

  describe "#add_fqdn" do
  end
end
