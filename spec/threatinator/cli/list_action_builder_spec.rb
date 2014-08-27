require 'spec_helper'
require 'threatinator/cli/list_action_builder'

describe Threatinator::CLI::ListActionBuilder do
  describe 'an instance' do
    let(:config_hash) { {} }
    let(:extra_args) { [] }
    let(:builder) { described_class.new(config_hash, extra_args) }

    it_behaves_like "an action builder"
    
    describe "#config" do
      context "when config_hash['list'] is provided" do
        let(:list_hash) { double('list hash') }
        before :each do
          config_hash['list'] = list_hash
        end
        it "builds a new Threatinator::Actions::List::Config using config_hash['list']" do
          expect(Threatinator::Actions::List::Config).to receive(:new).with(list_hash)
          builder.config
        end
      end
      context "when config_hash['list'] does not exist" do
        before :each do
          config_hash.delete 'list'
        end
        it "builds a new Threatinator::Config::FeedSearch using an empty hash" do
          expect(Threatinator::Actions::List::Config).to receive(:new).with({})
          builder.config
        end
      end
    end

    describe "#build" do
      let(:action) { double('action') }
      let(:config) { double('config') }
      let(:feed_registry) { double('feed registry') }
      before :each do
        allow(Threatinator::Actions::List::Action).to receive(:new).and_return(action)
        allow(builder).to receive(:config).and_return(config)
        allow(builder).to receive(:feed_registry).and_return(feed_registry)
      end

      let(:result) { builder.build }

      it "builds an instance of Threatinator::Actions::List::Action using #feed_registry and #config" do
        expect(Threatinator::Actions::List::Action).to receive(:new).with(feed_registry, config)
        builder.build
      end

      it "returns the instance of the action" do
        expect(builder.build).to be(action)
      end

    end
  end
end
