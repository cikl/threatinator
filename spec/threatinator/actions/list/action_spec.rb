require 'spec_helper'
require 'threatinator/actions/list/action'
require 'threatinator/actions/list/config'
require 'multi_json'

describe Threatinator::Actions::List::Action do
  let(:feed_registry) { build(:feed_registry) }
  let(:config) { Threatinator::Actions::List::Config.new }
  let(:action) { described_class.new(feed_registry, config) }

  shared_examples_for 'table output' do
    describe "the header row, header separator, and footer separator" do
      it "should vary the width of 'provider' based on the longest provider name" do
        1.upto(3) do |i|
          feed_registry.register(build(:feed, :http, url: "http://#{i}", name:i.to_s, provider: ('A' * (10 * i))))
        end

        output = temp_stdout do
          action.exec
        end
        lines = output.lines.to_a
        expect(lines[0]).to eq("provider                        name  type  link/path\n")
        expect(lines[1]).to eq("------------------------------  ----  ----  ---------\n")
        expect(lines[-2]).to eq("------------------------------  ----  ----  ---------\n")
      end

      it "should vary the width of 'name' based on the longest feed name" do
        1.upto(3) do |i|
          feed_registry.register(build(:feed, :http, url: "http://#{i}", provider:i.to_s, name: ('A' * (10 * i))))
        end

        output = temp_stdout do
          action.exec
        end
        lines = output.lines.to_a
        expect(lines[0]).to eq("provider  name                            type  link/path\n")
        expect(lines[1]).to eq("--------  ------------------------------  ----  ---------\n")
        expect(lines[-2]).to eq("--------  ------------------------------  ----  ---------\n")
      end

      it "should vary the width of 'link/path' based on the longest link name" do
        1.upto(3) do |i|
          feed_registry.register(build(:feed, :http, url: 'http://' + ('A' * (i * 10)), provider:i.to_s,name:i.to_s))
        end

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

  shared_examples_for 'json output' do
    describe "the output" do
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

        data = MultiJson.load(output)
        expect(data).to match(
          [
            {'provider' => 'provider_a', 'name' => 'feed_a', 'type' => kind_of(String), 'link' => kind_of(String)},
            {'provider' => 'provider_a', 'name' => 'feed_b', 'type' => kind_of(String), 'link' => kind_of(String)},
            {'provider' => 'provider_a', 'name' => 'feed_c', 'type' => kind_of(String), 'link' => kind_of(String)},
            {'provider' => 'provider_a', 'name' => 'feed_d', 'type' => kind_of(String), 'link' => kind_of(String)},
            {'provider' => 'provider_b', 'name' => 'feed_a', 'type' => kind_of(String), 'link' => kind_of(String)},
            {'provider' => 'provider_b', 'name' => 'feed_b', 'type' => kind_of(String), 'link' => kind_of(String)},
            {'provider' => 'provider_b', 'name' => 'feed_c', 'type' => kind_of(String), 'link' => kind_of(String)},
            {'provider' => 'provider_b', 'name' => 'feed_d', 'type' => kind_of(String), 'link' => kind_of(String)}
          ]
        )
      end
    end
  end

  context "when list.format is not set" do
    it_behaves_like 'table output'
  end
  context "when list.format == 'table'" do
    before :each do
      config.format = 'table'
    end
    it_behaves_like 'table output'
  end

  context "when list.format == 'json'" do
    before :each do
      config.format = 'json'
    end
    it_behaves_like 'json output'
  end

end
