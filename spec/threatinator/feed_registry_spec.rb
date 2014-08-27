require 'spec_helper'
require 'threatinator/feed_registry'
require 'threatinator/config/feed_search'

describe Threatinator::FeedRegistry do
  def generate_feedfile(filename, provider, name, url = "https://foobar/#{provider}/#{name}.data")
    File.open(filename, "w") do |fio|
      fio.write <<EOS
provider "#{provider}"
name "#{name}"
fetch_http('#{url}')

parse_eachline(:separator => "\n") do |builder, line|
end
EOS
    end
  end

  let(:registry) { described_class.new }
  let(:ten_feeds) { 1.upto(10).map { |i| build(:feed, provider: "prov#{i}", name: "name#{i}") } }

  describe "#clear" do
    it "should remove all existing registrations" do
      ten_feeds.each do |feed|
        registry.register(feed)
      end
      expect(registry.count).to eq(10)
      registry.clear
      expect(registry.count).to eq(0)

      expect {
        ten_feeds.each do |feed|
          registry.register(feed)
        end
      }.not_to raise_error
      expect(registry.count).to eq(10)
    end
  end

  describe "#register" do
    it "should register the provided feed" do
      feed = build(:feed, provider: "my_provider", name: "my_name")
      registry.register(feed)
      expect(registry.get("my_provider", "my_name")).to be(feed)
    end
    it "should return the feed that was registered" do
      feed = build(:feed, provider: "my_provider", name: "my_name")
      expect(registry.register(feed)).to be(feed)
    end
    it "should raise a AlreadyRegisteredError if a feed is already registered with the provider and name" do
      feed1 = build(:feed, provider: "my_provider", name: "my_name")
      feed2 = build(:feed, provider: "my_provider", name: "my_name")
      registry.register(feed1)
      expect { 
        registry.register(feed2)
      }.to raise_error(Threatinator::Exceptions::AlreadyRegisteredError)
    end

    it "should raise a AlreadyRegisteredError if the same feed is registered twice" do
      feed = build(:feed, provider: "my_provider", name: "my_name")
      registry.register(feed)
      expect { 
        registry.register(feed)
      }.to raise_error(Threatinator::Exceptions::AlreadyRegisteredError)
    end
  end

  describe "#register_from_file" do
    let(:feedfile) {FEED_FIXTURES.join("provider1", "feed1.feed").to_s}

    it "should return the feed after parsing the file" do
      ret = registry.register_from_file(feedfile)
      expect(ret).to be_a(Threatinator::Feed)
      expect(ret.provider).to eq("provider1")
      expect(ret.name).to eq("feed1")
    end

    it "should have registered the feed" do
      expect(registry.count).to eq(0)
      feed = registry.register_from_file(feedfile)
      expect(registry.count).to eq(1)
      expect(registry.get(feed.provider, feed.name)).to be(feed)
    end
  end

  describe "#each" do
    it "should enumerate through each reigstered feed" do
      ten_feeds.each do |feed|
        registry.register(feed)
      end
      found_feeds = []
      registry.each do |feed|
        found_feeds << feed
      end
      expect(found_feeds).to match_array(ten_feeds)
    end
  end

  describe "#count" do
    it "should return the number of feeds contained within the registry" do
      expect(registry.count).to eq(0)
      ten_feeds.each do |feed|
        registry.register(feed)
      end
      expect(registry.count).to eq(10)
    end
  end

  describe "#get" do
    it "should return nil if the provider/name isn't registered" do
      registry.register(build(:feed, provider: "my_provider", name: "my_name"))
      expect(registry.get("asdf", "1234")).to be_nil
    end
    it "should return the correct feed for the given provider and name" do
      ten_feeds.each { |feed| registry.register(feed) }
      feed = build(:feed, provider: "my_provider", name: "my_name")
      registry.register(feed)
      expect(registry.get("my_provider", "my_name")).to be(feed)
    end
  end

  describe ".build(feed_search_config)" do
    context "with no feed paths" do
      let(:feed_search_config) {
        Threatinator::Config::FeedSearch.new(exclude_default: true, path: [] )
      }
      let(:registry) { described_class.build(feed_search_config) }

      it "should not have loaded any feeds" do
        expect(registry.count).to eq(0)
      end
    end

    context "with feed search paths" do
      let(:feed_search_config) {
        Threatinator::Config::FeedSearch.new(exclude_default: true, path: [
          @feed_path1, @feed_path2
        ] )
      }
      before :each do
        @feed_path1 = Dir.mktmpdir
        @feed_path2 = Dir.mktmpdir
      end

      after :each do
        FileUtils.remove_entry_secure @feed_path1
        FileUtils.remove_entry_secure @feed_path2
      end

      it "should load feeds from all of the configured paths" do
        5.times do |i|
          generate_feedfile(File.join(@feed_path1, "feed#{i}.feed"), "provider1", "feed#{i}")
          generate_feedfile(File.join(@feed_path2, "feed#{i}.feed"), "provider2", "feed#{i}")
        end
        registry = described_class.build(feed_search_config) 
        expect(registry.count).to eq(10)
      end

      it "should ignore files that don't end with .feed" do
        generate_feedfile(File.join(@feed_path1, "feed1.fee"), "provider1", "feed1")
        generate_feedfile(File.join(@feed_path1, "feed1.fed"), "provider1", "feed2")
        generate_feedfile(File.join(@feed_path1, "feed1.rb"), "provider1", "feed3")
        generate_feedfile(File.join(@feed_path1, "feed1.feed"), "real_provider", "my_feed")
        registry = described_class.build(feed_search_config) 
        expect(registry.count).to eq(1)
        expect(registry.get("real_provider", "my_feed")).to be_a(Threatinator::Feed)
        expect(registry.get("provider1", "feed1")).to be_nil
        expect(registry.get("provider1", "feed2")).to be_nil
        expect(registry.get("provider1", "feed3")).to be_nil
      end

      it "should recurse subdirectories, loading feeds from there" do
        level1 = File.join(@feed_path1, "level1")
        level2 = File.join(@feed_path1, "level1", "level2")
        level3 = File.join(@feed_path1, "level1", "level2", "level3")
        FileUtils.mkdir_p level1
        FileUtils.mkdir_p level2
        FileUtils.mkdir_p level3
        generate_feedfile(File.join(level1, "feed1.feed"), "provider1", "feed1")
        generate_feedfile(File.join(level2, "feed2.feed"), "provider1", "feed2")
        generate_feedfile(File.join(level3, "feed3.feed"), "provider1", "feed3")
        registry = described_class.build(feed_search_config) 
        expect(registry.count).to eq(3)
      end

      it "should raise an exception if the same feed provider/name combination appears in multiple files" do
        generate_feedfile(File.join(@feed_path1, "feed1.feed"), "provider1", "feed1")
        generate_feedfile(File.join(@feed_path1, "feed2.feed"), "provider1", "feed1")
        expect {
          described_class.build(feed_search_config) 
        }.to raise_error(Threatinator::Exceptions::AlreadyRegisteredError)
      end

    end


  end
end
