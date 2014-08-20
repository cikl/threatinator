require 'spec_helper'
require 'threatinator/cli'
require 'fileutils'

shared_context "threatinator commands" do
  let(:action) { double('action') }
  let(:builder) { double('builder') }

  before :each do
    allow(action_builder_class).to receive(:new).and_return(builder)
    allow(builder).to receive(:build).and_return(action)
    allow(action).to receive(:exec)
  end

end
shared_examples_for "a threatinator command" do
  context '--feed_search.path=foo/bar' do
    before :each do
      global_args << '--feed_search.path=foo/bar'
      Threatinator::CLI.process!(args)
    end

    it "generates the proper config hash" do
      expect(action_builder_class).to have_received(:new) do |opts, args, *extra| 
        expect(opts).to match(
          {
            'feed_search' => {
              'exclude_default' => false,
              'path' => ['foo/bar']
            }
          }
        )
        expect(args).to eq([])
      end
    end
  end

  context '--feed_search.path=foo/bar,woof/bark' do
    before :each do
      global_args << '--feed_search.path=foo/bar,woof/bark'
      Threatinator::CLI.process!(args)
    end

    it "generates the proper config hash" do
      expect(action_builder_class).to have_received(:new) do |opts, args, *extra|
        expect(opts).to match(
          {
            'feed_search' => {
              'exclude_default' => false,
              'path' => ['foo/bar', 'woof/bark']
            }
          }
        )
        expect(args).to eq([])
      end
    end
  end

  context '--feed_search.exclude_default' do
    before :each do
      global_args << '--feed_search.exclude_default'
      Threatinator::CLI.process!(args)
    end

    it "generates the proper config hash" do
      expect(action_builder_class).to have_received(:new).with({
        'feed_search' => {
          'exclude_default' => true
        }
      }, [],
      kind_of(Class)
     )
    end
  end

  context "--help" do
    before :each do
      global_args << '--help'
      @exception = nil
      @exit_code = nil

      @captured_output = temp_stdout do
        @exit_code = Threatinator::CLI.process!(args)
      end
    end

    it "should have an exit code of 0" do
      expect(@exit_code).to eq(0)
    end

    it "should print usage information" do
      expect(@captured_output).to match(/^NAME/)
    end

    it "should not create an action builder" do
      expect(action_builder_class).not_to have_received(:new)
    end
  end
end

describe Threatinator::CLI do
  let(:global_args) { [] }
  let(:command) { [] }
  let(:command_args) { [] }
  let(:args) { global_args + [ command ] + command_args }

  describe "list command" do
    let(:command) { 'list' }
    let(:action) { double('action') }
    let(:builder) { double('builder') }

    before :each do
      allow(Threatinator::CLI::ListActionBuilder).to receive(:new).and_return(builder)
      allow(builder).to receive(:build).and_return(action)
      allow(action).to receive(:exec)
    end

    it "should create a ListActionBuilder" do
      Threatinator::CLI.process!(args)
      expect(Threatinator::CLI::ListActionBuilder).to have_received(:new).with({"feed_search" => {"exclude_default" => false}}, [])
    end

    it "should build an action" do
      Threatinator::CLI.process!(args)
      expect(builder).to have_received(:build)
    end

    it "should execute a list action" do
      Threatinator::CLI.process!(args)
      expect(action).to have_received(:exec)
    end
  end

  describe "run" do
    let(:action_builder_class) { Threatinator::CLI::RunActionBuilder }
    let(:command) { 'run' }
    include_context "threatinator commands"

    context "with no additional arguments" do
      it "should create an action builder with no config or args" do
        Threatinator::CLI.process!(args)
        expect(action_builder_class).to have_received(:new).with(
          {
            "feed_search" => {
              "exclude_default" => false
            }
          }, [], kind_of(Class))
      end
    end

    context "feed_provider feed_name" do
      before :each do
        command_args << 'feed_provider'
        command_args << 'feed_name'
      end
      it "should create an action builder with args feed_provider feed_name" do
        Threatinator::CLI.process!(args)
        expect(action_builder_class).to have_received(:new).with(
          {
            "feed_search" => {
              "exclude_default" => false
            }, 
            "run" => {
              "feed_provider" => "feed_provider", 
              "feed_name" => "feed_name"
            }
          }, [], kind_of(Class)
        )
      end
    end

    it_should_behave_like "a threatinator command"
  end
end

