require 'spec_helper'
require 'threatinator/event'

describe Threatinator::Event do
  describe "feed_provider" do
    it "can be set to a String" do
      expect(described_class.new(feed_provider: "asdf").feed_provider).to eq("asdf")
    end
    
    it "must be a String" do
      x = described_class.new(feed_provider: 1234)
      expect {
        x.validate!
      }.to raise_error(Threatinator::Exceptions::InvalidAttributeError)
    end

    it "is required" do
      x = described_class.new
      expect {
        x.validate!
      }.to raise_error(Threatinator::Exceptions::InvalidAttributeError)
    end
  end
  describe "feed_name" do
    it "can be set to a String" do
      expect(described_class.new(feed_name: "foo").feed_name).to eq("foo")
    end
  end
  describe "type" do
    let(:event) { described_class.new(feed_provider: "foo", feed_name: "bar", type: type) }
    let(:type) { nil }
    describe ":c2" do
      let(:type) { :c2 }
      it "is valid" do
        expect { event.validate! }.not_to raise_error
      end
    end
    describe ":attacker" do
      let(:type) { :attacker }
      it "is valid" do
        expect { event.validate! }.not_to raise_error
      end
    end
    describe ":malware_host" do
      let(:type) { :malware_host }
      it "is valid" do
        expect { event.validate! }.not_to raise_error
      end
    end
    describe ":spamming" do
      let(:type) { :spamming }
      it "is valid" do
        expect { event.validate! }.not_to raise_error
      end
    end
    describe ":scanning" do
      let(:type) { :scanning }
      it "is valid" do
        expect { event.validate! }.not_to raise_error
      end
    end
    describe ":phishing" do
      let(:type) { :phishing }
      it "is valid" do
        expect { event.validate! }.not_to raise_error
      end
    end
    describe "an invalid type" do
      let(:type) { :foo }
      it "is not valid" do
        expect { event.validate! }.to raise_error(Threatinator::Exceptions::InvalidAttributeError)
      end
    end
  end

  describe "#add_fqdn(fqdn)" do
    it "adds an fqdn" do
      x = described_class.new
      expect(x.fqdns).to eq([])
      x.add_fqdn('foo.com')
      expect(x.fqdns).to eq(['foo.com'])
      x.add_fqdn('bar.com')
      expect(x.fqdns).to eq(['foo.com', 'bar.com'])
    end
  end

  describe "#ipv4s" do
    it "should return an array"
  end

  describe "#add_ipv4(ipv4)" do
    it "adds an ipv4" do
      x = described_class.new
      expect(x.ipv4s).to eq([])
      x.add_ipv4('1.2.3.4')
      expect(x.ipv4s).to eq(['1.2.3.4'])
      x.add_ipv4('8.8.8.8')
      expect(x.ipv4s).to eq(['1.2.3.4', '8.8.8.8'])
    end
  end
end
