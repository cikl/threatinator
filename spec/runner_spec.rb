require 'spec_helper'
require 'threatinator/runner'

describe Threatinator::Runner do
  let(:default_feed_path) {File.expand_path("../../feeds", __FILE__)}
  let(:spec_feed_path) { File.expand_path("../support/feeds", __FILE__)}
  let(:runner) { Threatinator::Runner.new }

  describe "#add_feed_path" do
    it "add the paths to #feed_paths" do
      expect(runner.feed_paths).to eq([])
      runner.add_feed_path("/foo/bar1")
      expect(runner.feed_paths).to eq(["/foo/bar1"])
      runner.add_feed_path("/foo/bar2")
      expect(runner.feed_paths).to eq(["/foo/bar1", "/foo/bar2"])
    end
  end

  describe "#_load_feeds" do
    def generate_feedfile(filename, provider, name)
      File.open(filename, "w") do |fio|
        fio.write <<EOS
provider "#{provider}"
name "#{name}"
fetch_http('https://foobar/feed1.data')

parse_eachline(:separator => "\n") do |builder, line|
end
EOS
      end
    end

    before :each do
      @feed_path1 = Dir.mktmpdir
      @feed_path2 = Dir.mktmpdir
    end

    after :each do
      FileUtils.remove_entry_secure @feed_path1
      FileUtils.remove_entry_secure @feed_path2
    end

    context "with no feed paths" do
      it "should not have loaded any feeds" do
        runner._load_feeds
        expect(runner.registry.count).to eq(0)
      end
    end

    context "with paths added to the runner" do
      before :each do
        runner.add_feed_path(@feed_path1)
        runner.add_feed_path(@feed_path2)
      end

      it "should load feeds from all of the configured paths" do
        5.times do |i|
          generate_feedfile(File.join(@feed_path1, "feed#{i}.feed"), "provider1", "feed#{i}")
          generate_feedfile(File.join(@feed_path2, "feed#{i}.feed"), "provider2", "feed#{i}")
        end
        runner._load_feeds
        expect(runner.registry.count).to eq(10)
      end

      it "should ignore files that don't end with .feed" do
        generate_feedfile(File.join(@feed_path1, "feed1.fee"), "provider1", "feed1")
        generate_feedfile(File.join(@feed_path1, "feed1.fed"), "provider1", "feed2")
        generate_feedfile(File.join(@feed_path1, "feed1.rb"), "provider1", "feed3")
        generate_feedfile(File.join(@feed_path1, "feed1.feed"), "real_provider", "my_feed")
        runner._load_feeds
        expect(runner.registry.count).to eq(1)
        expect(runner.registry.get("real_provider", "my_feed")).to be_a(Threatinator::Feed)
        expect(runner.registry.get("provider1", "feed1")).to be_nil
        expect(runner.registry.get("provider1", "feed2")).to be_nil
        expect(runner.registry.get("provider1", "feed3")).to be_nil
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
        runner._load_feeds
        expect(runner.registry.count).to eq(3)
      end

      it "should raise an exception if the same feed provider/name combination appears in multiple files" do
        generate_feedfile(File.join(@feed_path1, "feed1.feed"), "provider1", "feed1")
        generate_feedfile(File.join(@feed_path1, "feed2.feed"), "provider1", "feed1")
        expect {
          runner._load_feeds
        }.to raise_error(Threatinator::Exceptions::FeedAlreadyRegisteredError)
      end

    end
  end

  describe "#_register_feed_from_file" do
    let(:feedfile) {File.expand_path("../support/feeds/provider1/feed1.feed", __FILE__)}

    it "should return the feed after parsing the file" do
      ret = runner._register_feed_from_file(feedfile)
      expect(ret).to be_a(Threatinator::Feed)
      expect(ret.provider).to eq("provider1")
      expect(ret.name).to eq("feed1")
    end

    it "should have registered the feed" do
      expect(runner.registry.count).to eq(0)
      feed = runner._register_feed_from_file(feedfile)
      expect(runner.registry.count).to eq(1)
      expect(runner.registry.get(feed.provider, feed.name)).to be(feed)
    end
  end

  describe "#run" do
    it "should call #load_feeds" do
    end
  end

end
