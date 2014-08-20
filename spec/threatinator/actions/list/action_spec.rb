require 'spec_helper'
require 'threatinator/actions/list/action'
require 'threatinator/actions/list/config'

describe Threatinator::Actions::List::Action do
  let(:feed_registry) { build(:feed_registry) }
  let(:config) { Threatinator::Actions::List::Config.new }
  let(:action) { described_class.new(feed_registry, config) }

  describe "the header row, header separator, and footer separator" do
    it "should vary the width of 'provider' based on the longest provider name" do
      feed_registry.register(build(:feed, :mini, provider: 'A' * 10))
      feed_registry.register(build(:feed, :mini, provider: 'A' * 20))
      feed_registry.register(build(:feed, :mini, provider: 'A' * 30))

      output = temp_stdout do
        action.exec
      end
      lines = output.lines.to_a
      expect(lines[0]).to eq("provider                        name  type  link/path\n")
      expect(lines[1]).to eq("------------------------------  ----  ----  ---------\n")
      expect(lines[-2]).to eq("------------------------------  ----  ----  ---------\n")
    end

    it "should vary the width of 'name' based on the longest feed name" do
      feed_registry.register(build(:feed, :mini, name: 'A' * 10))
      feed_registry.register(build(:feed, :mini, name: 'A' * 20))
      feed_registry.register(build(:feed, :mini, name: 'A' * 30))

      output = temp_stdout do
        action.exec
      end
      lines = output.lines.to_a
      expect(lines[0]).to eq("provider  name                            type  link/path\n")
      expect(lines[1]).to eq("--------  ------------------------------  ----  ---------\n")
      expect(lines[-2]).to eq("--------  ------------------------------  ----  ---------\n")
    end

    it "should vary the width of 'link/path' based on the longest link name" do
      feed_registry.register(build(:feed, :mini, url: 'http://' + ('A' * 10)))
      feed_registry.register(build(:feed, :mini, url: 'http://' + ('A' * 20)))
      feed_registry.register(build(:feed, :mini, url: 'http://' + ('A' * 30)))

      output = temp_stdout do
        action.exec
      end
      lines = output.lines.to_a
      expect(lines[0]).to eq("provider  name  type  link/path                            \n")
      expect(lines[1]).to eq("--------  ----  ----  -------------------------------------\n")
      expect(lines[-2]).to eq("--------  ----  ----  -------------------------------------\n")
    end
  end

  describe "the list of feeds" do
    it "should be sorted by provider name and then feed name" do
      feed_registry.register(build(:feed, provider: 'provider_b', name: 'feed_c' ))
      feed_registry.register(build(:feed, provider: 'provider_a', name: 'feed_d' ))
      feed_registry.register(build(:feed, provider: 'provider_a', name: 'feed_a' ))
      feed_registry.register(build(:feed, provider: 'provider_b', name: 'feed_d' ))
      feed_registry.register(build(:feed, provider: 'provider_a', name: 'feed_c' ))
      feed_registry.register(build(:feed, provider: 'provider_b', name: 'feed_a' ))
      feed_registry.register(build(:feed, provider: 'provider_b', name: 'feed_b' ))
      feed_registry.register(build(:feed, provider: 'provider_a', name: 'feed_b' ))

      output = temp_stdout do
        action.exec
      end
      lines = output.lines.to_a
      expect(lines[2]).to match(/^provider_a  feed_a  .*$/)
      expect(lines[3]).to match(/^provider_a  feed_b  .*$/)
      expect(lines[4]).to match(/^provider_a  feed_c  .*$/)
      expect(lines[5]).to match(/^provider_a  feed_d  .*$/)
      expect(lines[6]).to match(/^provider_b  feed_a  .*$/)
      expect(lines[7]).to match(/^provider_b  feed_b  .*$/)
      expect(lines[8]).to match(/^provider_b  feed_c  .*$/)
      expect(lines[9]).to match(/^provider_b  feed_d  .*$/)
    end
  end

  describe "the footer" do
    it "should indicate the number of feeds" do
      20.times do |i|
        feed_registry.register(build(:feed))
      end
      output = temp_stdout do
        action.exec
      end
      lines = output.lines.to_a
      expect(lines[-1]).to eq("Total: 20\n")
    end
  end

end
