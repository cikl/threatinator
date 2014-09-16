require 'spec_helper'
require 'threatinator/event'

describe Threatinator::Event do
  it "requires at least :feed_provider, :feed_name, and :type to be valid" do
    event = described_class.new(feed_provider: 'foo', feed_name: 'bar', type: :c2)
    expect(event).to be_valid
  end

  let(:event_opts) { { feed_provider: 'foo', feed_name: 'bar', type: :c2 } }

  describe "#validate!" do
    it "doesn't raise anything when the event is valid" do
      event = described_class.new(event_opts)
      expect(event).to be_valid
      expect { event.validate! }.not_to raise_error
    end
    it "raises an InvalidAttributeError if the event is not valid" do
      event_opts.delete(:feed_name)
      event = described_class.new(event_opts)
      expect(event).not_to be_valid
      expect { event.validate! }.to raise_error(Threatinator::Exceptions::InvalidAttributeError)
    end
  end

  describe "#==(other)" do
    it "returns true when compared to an identically configured event" do
      event_opts.merge!(ipv4s: ['1.2.3.4'], fqdns: ['foo.com'])
      event1 = described_class.new(event_opts)
      event2 = described_class.new(event_opts)
      expect(event1).to be == event2
    end

    it "returns true when compared to an identically configured event" do
      event_opts.merge!(ipv4s: ['1.2.3.4'], fqdns: ['foo.com'])
      event1 = described_class.new(event_opts)
      event_opts.merge!(ipv4s: ['8.8.8.8'], fqdns: ['foo.com'])
      event2 = described_class.new(event_opts)
      expect(event1).not_to be == event2
    end
  end

  describe "feed_provider" do
    it "can be set to a String" do
      event_opts[:feed_provider] = "asdf"
      expect(described_class.new(event_opts).feed_provider).to eq("asdf")
    end
    
    it "is required to be a String" do
      event_opts[:feed_provider] = 1234
      x = described_class.new(event_opts)
      expect(x).not_to be_valid
    end

    it "is required" do
      event_opts.delete(:feed_provider)
      x = described_class.new(event_opts)
      expect(x).not_to be_valid
    end
  end

  describe "feed_name" do
    it "can be set to a String" do
      event_opts[:feed_name] = "foo"
      expect(described_class.new(event_opts).feed_name).to eq("foo")
    end

    it "is required to be a String" do
      event_opts[:feed_name] = 1234
      x = described_class.new(event_opts)
      expect(x).not_to be_valid
    end

  end

  describe "type" do
    let(:event) { described_class.new(event_opts) }
    context "when nil" do
      before :each do
        event_opts[:type] = nil
      end
      it "is not valid" do
        expect(event).not_to be_valid
      end
    end
    context "when not set" do
      before :each do
        event_opts.delete(:type)
      end
      it "is not valid" do
        expect(event).not_to be_valid
      end
    end
    describe ":c2" do
      before :each do
        event_opts[:type] = :c2
      end
      it "is valid" do
        expect(event).to be_valid
      end
    end
    describe ":attacker" do
      before :each do
        event_opts[:type] = :attacker
      end
      it "is valid" do
        expect(event).to be_valid
      end
    end
    describe ":malware_host" do
      before :each do
        event_opts[:type] = :malware_host
      end
      it "is valid" do
        expect(event).to be_valid
      end
    end
    describe ":spamming" do
      before :each do
        event_opts[:type] = :spamming
      end
      it "is valid" do
        expect(event).to be_valid
      end
    end
    describe ":scanning" do
      before :each do
        event_opts[:type] = :scanning
      end
      it "is valid" do
        expect(event).to be_valid
      end
    end
    describe ":phishing" do
      before :each do
        event_opts[:type] = :phishing
      end
      it "is valid" do
        expect(event).to be_valid
      end
    end
    describe "an invalid type" do
      before :each do
        event_opts[:type] = :foo
      end
      it "is not valid" do
        expect(event).not_to be_valid
      end
    end
  end

  describe "fqdns" do
    let(:event) { described_class.new(event_opts.merge({ fqdns: fqdns })) }
    context "with :fqdns set to nil" do
      let(:fqdns) { nil }
      it "is valid" do
        expect(event).to be_valid
      end
      describe "#fqdns" do
        it "returns an an empty array" do
          expect(event.fqdns).to be_empty
        end
      end
    end
    context "with :fqdns set to an empty array" do
      let(:fqdns) { [] }
      it "is valid" do
        expect(event).to be_valid
      end
      describe "#fqdns" do
        it "returns an an empty array" do
          expect(event.fqdns).to be_empty
        end
      end
    end
    context "with :fqdns set to an array of fqdn strings" do
      let(:fqdns) { ['foo.com', 'bar.com'] }
      it "is valid" do
        expect(event).to be_valid
      end
      describe "#fqdns" do
        it "returns an Array of Strings" do
          expect(event.fqdns).to contain_exactly('foo.com', 'bar.com')
        end
      end
    end
  end

  describe "ipv4s" do
    let(:event) { described_class.new(event_opts.merge({ ipv4s: ipv4s })) }
    context "with :ipv4s set to nil" do
      let(:ipv4s) { nil }
      it "is valid" do
        expect(event).to be_valid
      end
      describe "#ipv4s" do
        it "returns an an empty array" do
          expect(event.ipv4s).to be_empty
        end
      end
    end
    context "with :ipv4s set to an empty array" do
      let(:ipv4s) { [] }
      it "is valid" do
        expect(event).to be_valid
      end
      describe "#ipv4s" do
        it "returns an an empty array" do
          expect(event.ipv4s).to be_empty
        end
      end
    end
    context "with :ipv4s set to an array of ipv4 strings" do
      let(:ipv4s) { ['1.2.3.4', '8.8.8.8'] }
      it "is valid" do
        expect(event).to be_valid
      end
      describe "#ipv4s" do
        it "returns an Array of Strings" do
          expect(event.ipv4s).to contain_exactly('1.2.3.4', '8.8.8.8')
        end
      end
    end
  end

end
