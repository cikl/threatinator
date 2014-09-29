require 'spec_helper'
require 'threatinator/model/observables/ipv4'

describe Threatinator::Model::Observables::Ipv4 do
  let(:ipv4_opts) { {} }

  describe ":ipv4" do
    it "is required" do
      ipv4_opts.delete(:ipv4)
      expect {
        described_class.new(ipv4_opts)
      }.to raise_error(Threatinator::Exceptions::InvalidAttributeError)
    end

    it "must be an IP::V4 object" do
      opts1 = ipv4_opts.dup
      opts1[:ipv4] = '1.2.3.4'
      expect {
        described_class.new(opts1)
      }.to raise_error(Threatinator::Exceptions::InvalidAttributeError)

      opts2 = ipv4_opts.dup
      opts2[:ipv4] = IP::V4.parse('1.2.3.4')
      expect {
        described_class.new(opts2)
      }.not_to raise_error
    end

    it "must have a 32 bit prefix" do
      opts1 = ipv4_opts.dup
      opts1[:ipv4] = IP::V4.parse('10.1.1.0/24')
      expect {
        described_class.new(opts1)
      }.to raise_error(Threatinator::Exceptions::InvalidAttributeError)

      opts2 = ipv4_opts.dup
      opts2[:ipv4] = IP::V4.parse('10.1.1.0/32')
      expect {
        described_class.new(opts2)
      }.not_to raise_error
    end


    it "sets the value of #ipv4" do
      ipv4 = IP::V4.parse('1.2.3.4')
      ipv4_opts[:ipv4] = ipv4
      o = described_class.new(ipv4_opts)
      expect(o.ipv4).to be(ipv4)
    end
  end

  describe "#==(other)" do
    it "returns true when compared to an identically configured event" do
      opts1 = ipv4_opts.dup
      opts1[:ipv4] = IP::V4.parse('1.2.3.4')
      opts2 = ipv4_opts.dup
      opts2[:ipv4] = IP::V4.parse('1.2.3.4')
      o1 = described_class.new(opts1)
      o2 = described_class.new(opts2)
      expect(o1).to be == o2
    end

    it "returns false when compared to differently configured event" do
      opts1 = ipv4_opts.dup
      opts1[:ipv4] = IP::V4.parse('1.2.3.4')
      opts2 = ipv4_opts.dup
      opts2[:ipv4] = IP::V4.parse('8.8.8.8')
      o1 = described_class.new(opts1)
      o2 = described_class.new(opts2)
      expect(o1).not_to be == o2
    end
  end

end

