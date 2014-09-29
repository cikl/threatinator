require 'spec_helper'
require 'threatinator/event'

describe Threatinator::Event do

  let(:event_opts) { { feed_provider: 'foo', feed_name: 'bar', type: :c2 } }

  describe "initialization" do
    it "requires at least :feed_provider, :feed_name, and :type to be valid" do
      expect {
        described_class.new(feed_provider: 'foo', feed_name: 'bar', type: :c2)
      }.not_to raise_error
    end
  end

  describe "#==(other)" do
    it "returns true when compared to an identically configured event" do
      event_opts.merge!(ipv4s: build(:ipv4s, values: ['1.2.3.4']), fqdns: ['foo.com'])
      event1 = described_class.new(event_opts)
      event2 = described_class.new(event_opts)
      expect(event1).to be == event2
    end

    it "returns true when compared to an identically configured event" do
      event_opts.merge!(ipv4s: build(:ipv4s, values: ['1.2.3.4']), fqdns: ['foo.com'])
      event1 = described_class.new(event_opts)
      event_opts.merge!(ipv4s: build(:ipv4s, values: ['8.8.8.8']), fqdns: ['foo.com'])
      event2 = described_class.new(event_opts)
      expect(event1).not_to be == event2
    end
  end

  describe ":feed_provider" do
    it "can be set to a String" do
      event_opts[:feed_provider] = "asdf"
      expect(described_class.new(event_opts).feed_provider).to eq("asdf")
    end
    
    it "is required to be a String" do
      event_opts[:feed_provider] = 1234
      expect {
        described_class.new(event_opts)
      }.to raise_error(Threatinator::Exceptions::InvalidAttributeError)
    end

    it "is required" do
      event_opts.delete(:feed_provider)
      expect {
        described_class.new(event_opts)
      }.to raise_error(Threatinator::Exceptions::InvalidAttributeError)
    end
  end

  describe ":feed_name" do
    it "can be set to a String" do
      event_opts[:feed_name] = "foo"
      expect(described_class.new(event_opts).feed_name).to eq("foo")
    end

    it "is required to be a String" do
      event_opts[:feed_name] = 1234
      expect {
        described_class.new(event_opts)
      }.to raise_error(Threatinator::Exceptions::InvalidAttributeError)
    end

    it "is required" do
      event_opts.delete(:feed_name)
      expect {
        described_class.new(event_opts)
      }.to raise_error(Threatinator::Exceptions::InvalidAttributeError)
    end
  end

  describe ":type" do
    it "cannot be be nil" do
      event_opts[:type] = nil
      expect {
        described_class.new(event_opts)
      }.to raise_error(Threatinator::Exceptions::InvalidAttributeError)
    end
    it "is required" do
      event_opts.delete(:type)
      expect {
        described_class.new(event_opts)
      }.to raise_error(Threatinator::Exceptions::InvalidAttributeError)
    end
    [:c2, :attacker, :malware_host, :spamming, :scanning, :phishing].each do |v|
      it "can be #{v.inspect}" do
        event_opts[:type] = v
        expect(described_class.new(event_opts).type).to eq(v)
      end
    end
  end

  describe ":fqdns" do
    context "when nil" do
      it "is valid" do
        event_opts[:fqdns] = nil
        expect {
          described_class.new(event_opts)
        }.not_to raise_error
      end
      describe "#fqdns" do
        it "returns an an empty array" do
          event_opts[:fqdns] = nil
          expect(described_class.new(event_opts).fqdns).to be_empty
        end
      end
    end
    context "when set to an empty array" do
      it "is valid" do
        event_opts[:fqdns] = nil
        expect {
          described_class.new(event_opts)
        }.not_to raise_error
      end
      describe "#fqdns" do
        it "returns an an empty array" do
          event_opts[:fqdns] = []
          expect(described_class.new(event_opts).fqdns).to be_empty
        end
      end
    end
    context "with :fqdns set to an array of fqdn strings" do
      let(:fqdns) { ['foo.com', 'bar.com'] }
      it "is valid" do
        event_opts[:fqdns] = ['foo.com', 'bar.com']
        expect {
          described_class.new(event_opts)
        }.not_to raise_error
      end
      describe "#fqdns" do
        it "returns a collection containing the provided fqdns" do
          event_opts[:fqdns] = ['foo.com', 'bar.com']
          expect(described_class.new(event_opts).fqdns).to contain_exactly('foo.com', 'bar.com')
        end
      end
    end
  end


  describe ":ipv4s" do
    context "when nil" do
      it "is valid" do
        event_opts[:ipv4s] = nil
        expect {
          described_class.new(event_opts)
        }.not_to raise_error
      end
      describe "#ipv4s" do
        it "returns an an empty collection" do
          event_opts[:ipv4s] = nil
          expect(described_class.new(event_opts).ipv4s).to be_empty
        end
      end
    end
    context "when set to an empty array" do
      it "is valid" do
        event_opts[:ipv4s] = nil
        expect {
          described_class.new(event_opts)
        }.not_to raise_error
      end
      describe "#ipv4s" do
        it "returns an an empty collection" do
          event_opts[:ipv4s] = []
          expect(described_class.new(event_opts).ipv4s).to be_empty
        end
      end
    end
    context "with :ipv4s set to an empty Ipv4Collection" do
      it "is valid" do
        event_opts[:ipv4s] = build(:ipv4s)
        expect {
          described_class.new(event_opts)
        }.not_to raise_error
      end
      describe "#ipv4s" do
        it "returns an an empty collection" do
          event_opts[:ipv4s] = []
          expect(described_class.new(event_opts).ipv4s).to be_empty
        end
      end
    end
    context "with :ipv4s set to an array of Ipv4 observables" do
      it "is valid" do
        event_opts[:ipv4s] = [build(:ipv4, ipv4: '1.2.3.4'), build(:ipv4, ipv4: '8.8.8.8')]
        expect {
          described_class.new(event_opts)
        }.not_to raise_error
      end
      describe "#ipv4s" do
        it "returns a collection containing the provided Ipv4 observables" do
          o1 = build(:ipv4, ipv4: '1.2.3.4')
          o2 = build(:ipv4, ipv4: '8.8.8.8')
          event_opts[:ipv4s] = [o1, o2]
          expect(described_class.new(event_opts).ipv4s).to contain_exactly(o1, o2)
        end
      end
    end
  end

  describe ":urls" do
    context "when nil" do
      it "is valid" do
        event_opts[:urls] = nil
        expect {
          described_class.new(event_opts)
        }.not_to raise_error
      end
      describe "#urls" do
        it "returns an an empty array" do
          event_opts[:urls] = nil
          expect(described_class.new(event_opts).urls).to be_empty
        end
      end
    end
    context "when set to an empty array" do
      it "is valid" do
        event_opts[:urls] = nil
        expect {
          described_class.new(event_opts)
        }.not_to raise_error
      end
      describe "#urls" do
        it "returns an an empty array" do
          event_opts[:urls] = []
          expect(described_class.new(event_opts).urls).to be_empty
        end
      end
    end
    context "with :urls set to an array of url strings" do
      let(:urls) { 
        [
          Addressable::URI.parse('http://yahoo.com'),
          Addressable::URI.parse('http://google.com'),
        ]
      }
      it "is valid" do
        event_opts[:urls] = urls
        expect {
          described_class.new(event_opts)
        }.not_to raise_error
      end
      describe "#urls" do
        it "returns a collection containing the provided urls" do
          event_opts[:urls] = urls
          expect(described_class.new(event_opts).urls).to match_array(urls)
        end
      end
    end
  end
end
