require 'spec_helper'
require 'threatinator/runner'
require 'threatinator/outputs/null'

describe Threatinator::Runner do
  let(:default_feed_path) {File.expand_path("../../feeds", __FILE__)}
  let(:spec_feed_path) { File.expand_path("../support/feeds", __FILE__)}
  let(:runner) { Threatinator::Runner.new }

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
        }.to raise_error(Threatinator::Exceptions::AlreadyRegisteredError)
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

  describe "#list" do
    let(:io_out) { StringIO.new }

    before :each do
      @feed_path = Dir.mktmpdir
      runner.add_feed_path(@feed_path)
    end

    after :each do
      FileUtils.remove_entry_secure @feed_path
    end

    context "with no feed paths" do
      it "should output the header" do
        runner.list(io_out: io_out);
        lines = io_out.string.lines.to_a
        expect(lines[0]).to eq("provider  name  type  link/path\n")
        expect(lines[1]).to eq("--------  ----  ----  ---------\n")
      end

      it "should output the footer with a total of 0" do
        runner.list(io_out: io_out);
        lines = io_out.string.lines.to_a
        expect(lines[-2]).to eq("--------  ----  ----  ---------\n")
        expect(lines[-1]).to eq("Total: 0\n")
      end
    end

    context "with paths added to the runner" do
      before :each do
      end
      describe "the header row, header separator, and footer separator" do
        it "should vary the width of 'provider' based on the longest provider name" do
          generate_feedfile(File.join(@feed_path, "feed.feed"), "A" * 10, "x", "http://x")
          generate_feedfile(File.join(@feed_path, "feed.feed"), "A" * 20, "x", "http://x")
          generate_feedfile(File.join(@feed_path, "feed.feed"), "A" * 30, "x", "http://x")

          runner.list(io_out: io_out);
          lines = io_out.string.lines.to_a
          expect(lines[0]).to eq("provider                        name  type  link/path\n")
          expect(lines[1]).to eq("------------------------------  ----  ----  ---------\n")
          expect(lines[-2]).to eq("------------------------------  ----  ----  ---------\n")
        end

        it "should vary the width of 'name' based on the longest feed name" do
          generate_feedfile(File.join(@feed_path, "feed.feed"), 'a', "A" * 10, "http://x")
          generate_feedfile(File.join(@feed_path, "feed.feed"), 'a', "A" * 20, "http://x")
          generate_feedfile(File.join(@feed_path, "feed.feed"), 'a', "A" * 30, "http://x")

          runner.list(io_out: io_out);
          lines = io_out.string.lines.to_a
          expect(lines[0]).to eq("provider  name                            type  link/path\n")
          expect(lines[1]).to eq("--------  ------------------------------  ----  ---------\n")
          expect(lines[-2]).to eq("--------  ------------------------------  ----  ---------\n")
        end

        it "should vary the width of 'link/path' based on the longest link name" do
          generate_feedfile(File.join(@feed_path, "feed.feed"), 'a', 'b', "http://" + ("A" * 10))
          generate_feedfile(File.join(@feed_path, "feed.feed"), 'a', 'b', "http://" + ("A" * 20))
          generate_feedfile(File.join(@feed_path, "feed.feed"), 'a', 'b', "http://" + ("A" * 30))

          runner.list(io_out: io_out);
          lines = io_out.string.lines.to_a
          expect(lines[0]).to eq("provider  name  type  link/path                            \n")
          expect(lines[1]).to eq("--------  ----  ----  -------------------------------------\n")
          expect(lines[-2]).to eq("--------  ----  ----  -------------------------------------\n")
        end
      end

      describe "the list of feeds" do
        it "should be sorted by provider name and then feed name" do
          generate_feedfile(File.join(@feed_path, "feed1.feed"), 'provider_b', 'feed_c')
          generate_feedfile(File.join(@feed_path, "feed2.feed"), 'provider_a', 'feed_d')
          generate_feedfile(File.join(@feed_path, "feed3.feed"), 'provider_a', 'feed_a')
          generate_feedfile(File.join(@feed_path, "feed4.feed"), 'provider_b', 'feed_d')
          generate_feedfile(File.join(@feed_path, "feed5.feed"), 'provider_a', 'feed_c')
          generate_feedfile(File.join(@feed_path, "feed6.feed"), 'provider_b', 'feed_a')
          generate_feedfile(File.join(@feed_path, "feed7.feed"), 'provider_b', 'feed_b')
          generate_feedfile(File.join(@feed_path, "feed8.feed"), 'provider_a', 'feed_b')

          runner.list(io_out: io_out);
          lines = io_out.string.lines.to_a
          expect(lines[2]).to eq("provider_a  feed_a  http  https://foobar/provider_a/feed_a.data\n")
          expect(lines[3]).to eq("provider_a  feed_b  http  https://foobar/provider_a/feed_b.data\n")
          expect(lines[4]).to eq("provider_a  feed_c  http  https://foobar/provider_a/feed_c.data\n")
          expect(lines[5]).to eq("provider_a  feed_d  http  https://foobar/provider_a/feed_d.data\n")

          expect(lines[6]).to eq("provider_b  feed_a  http  https://foobar/provider_b/feed_a.data\n")
          expect(lines[7]).to eq("provider_b  feed_b  http  https://foobar/provider_b/feed_b.data\n")
          expect(lines[8]).to eq("provider_b  feed_c  http  https://foobar/provider_b/feed_c.data\n")
          expect(lines[9]).to eq("provider_b  feed_d  http  https://foobar/provider_b/feed_d.data\n")
        end
      end

      describe "the footer" do
        it "should indicate the number of feeds" do
          20.times do |i|
            generate_feedfile(File.join(@feed_path, "feed#{i}.feed"), "a#{i}", 'b', "http://" + ("A" * 10))
          end
          runner.list(io_out: io_out);
          lines = io_out.string.lines.to_a
          expect(lines[-1]).to eq("Total: 20\n")
        end
      end
    end
  end

  describe "#run" do
    before :each do
      @feed_path = Dir.mktmpdir
      generate_feedfile(File.join(@feed_path, "feed1.feed"), "provider1", "feed1")
      runner.add_feed_path(@feed_path)
      allow(Threatinator::FeedRunner).to receive(:run)
    end

    after :each do
      FileUtils.remove_entry_secure @feed_path
    end

    let(:output) { Threatinator::Plugins.get_output_by_name(:null) } 

    it "parses all the feeds" do
      expect(runner).to receive(:_load_feeds).and_call_original
      runner.run("provider1", "feed1", output)
    end

    context "when called with a provider and feed name that does not match a feed" do
      it "raises Threatinator::Exceptions::UnknownFeed" do
        expect {
          runner.run("foobar", "bla", output)
        }.to raise_error(Threatinator::Exceptions::UnknownFeed)
      end
    end

    context "when called with a provider and feed name that matches a feed" do
      it "loads the feed by the given provider and name" do
        expect(runner.registry).to receive(:get).with("provider1", "feed1").and_call_original
        runner.run("provider1", "feed1", output)
      end

      it "runs the feed" do
        opts_hash = {foo: 123}
        expect(Threatinator::FeedRunner).to receive(:run).with(kind_of(Threatinator::Feed), output, opts_hash)
        runner.run("provider1", "feed1", output, opts_hash)
      end
    end
  end

end
