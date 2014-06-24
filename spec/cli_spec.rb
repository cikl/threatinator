require 'spec_helper'
require 'threatinator/cli'
require 'threatinator/runner'

shared_examples_for "a command parsing path options" do
  describe "--help" do
    it "should exit the process" do
      args << '--help'
      temp_stdout do 
        expect {
          Threatinator::CLI.process!(args, mock_runner)
        }.to raise_error(SystemExit)
      end
    end
  end
  describe "default path handling" do
    it "should add the default feed path by default" do
      expect(mock_runner).to receive(:add_feed_path).with(Threatinator::CLI::DEFAULT_FEED_PATH)
      Threatinator::CLI.process!(args, mock_runner)
    end
    ["-x", "--exclude-default-path"].each do |operator|
      describe operator do
        before :each do
          args << operator
        end
        it "should not add the default feed path" do
          expect(mock_runner).not_to receive(:add_feed_path)
          Threatinator::CLI.process!(args, mock_runner)
        end
      end
    end
  end

  describe "dry run" do
    ["-n", "--dryrun"].each do |operator|
      describe operator do
        context "when specified" do
          before :each do
            args << operator
          end
          it "should not call the command" do
            expect(mock_runner).not_to receive(command_method)
            Threatinator::CLI.process!(args, mock_runner)
          end
        end
        context "when not specified" do
          it "should call the command" do
            expect(mock_runner).to receive(command_method)
            Threatinator::CLI.process!(args, mock_runner)
          end
        end
      end
    end
  end

  describe "adding paths" do
    ["-p", "--path"].each do |operator|
      describe operator do
        context "when specified once: #{operator} /some/path" do
          before :each do
            args.concat %W[#{operator} /some/path]
            allow(mock_runner).to receive(:add_feed_path).with(Threatinator::CLI::DEFAULT_FEED_PATH)
          end

          it "should add the path to the runner" do
            expect(mock_runner).to receive(:add_feed_path).with('/some/path')
            Threatinator::CLI.process!(args, mock_runner)
          end
        end

        context "when specified multiple times: #{operator} /some/path1 #{operator} /some/path2 " do
          before :each do
            args.concat %W[#{operator} /some/path1 #{operator} /some/path2 ]
            allow(mock_runner).to receive(:add_feed_path).with(Threatinator::CLI::DEFAULT_FEED_PATH)
          end

          it "should add each path to the runner" do
            expect(mock_runner).to receive(:add_feed_path).with('/some/path1')
            expect(mock_runner).to receive(:add_feed_path).with('/some/path2')
            Threatinator::CLI.process!(args, mock_runner)
          end
        end

        context "when specifying multiple paths, but comman separated: #{operator} /some/path1,/some/path2" do
          before :each do
            args.concat %W[#{operator} /some/path1,/some/path2]
            allow(mock_runner).to receive(:add_feed_path).with(Threatinator::CLI::DEFAULT_FEED_PATH)
          end

          it "should add each path to the runner" do
            expect(mock_runner).to receive(:add_feed_path).with('/some/path1')
            expect(mock_runner).to receive(:add_feed_path).with('/some/path2')
            Threatinator::CLI.process!(args, mock_runner)
          end
        end

      end
    end
  end


end

describe Threatinator::CLI do
  let(:args) { [] }
  describe "list command" do
    let(:mock_runner) { double("runner") }
    let(:args) { %w[list] }
    before :each do
      allow(mock_runner).to receive(:add_feed_path)
      allow(mock_runner).to receive(:list)
    end

    it "should call runner.list" do
      expect(mock_runner).to receive(:list)
      Threatinator::CLI.process!(args, mock_runner)
    end

    it_should_behave_like "a command parsing path options" do
      let(:command_method) { :list }
    end

  end

  describe "run command" do
    let(:mock_runner) { double("runner") }
    let(:args) { %w[run myprovider myname] }
    before :each do
      allow(mock_runner).to receive(:add_feed_path)
      allow(mock_runner).to receive(:run)
    end

    it "should call runner.run" do
      expect(mock_runner).to receive(:run)
      Threatinator::CLI.process!(args, mock_runner)
    end

    it_should_behave_like "a command parsing path options" do
      let(:command_method) { :run }
    end
  end

end

