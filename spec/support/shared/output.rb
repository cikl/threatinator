require 'spec_helper'
require 'tempfile'
require 'threatinator/plugin_loader'

shared_examples_for "an output plugin" do |name|
  let(:output) { described_class.new(config) }

  specify "the plugin loader should find the class by (#{name.inspect})" do
    loader = Threatinator::PluginLoader.new
    loader.load_plugins(:output)
    expect(loader.get(:output, name.to_sym)).to be(described_class)
  end
end

shared_examples_for "a file-based output plugin" do |name|
  it_should_behave_like "an output plugin", name

  let(:event) { build(:event) }

  describe "config.io => IO" do
    let(:output) { described_class.new(config) }
    let(:io) { StringIO.new }
    before :each do
      config.io = io
    end

    describe "#handle_event" do
      before :each do
        output.handle_event(event)
      end

      it "writes data to the provided IO" do
        expect(io.string).not_to be_empty
      end
    end

    describe "#finish" do
      before :each do
        allow(io).to receive(:close)
        output.finish
      end

      it "closes the IO" do
        expect(io).to have_received(:close)
      end
    end
  end

  describe "config.filename => String" do
    let(:output) { described_class.new(config) }
    before :each do
      @tempfile = Tempfile.new("asdf")
      @tempfile.close
      @filepath = @tempfile.path
      config.filename = @filepath
    end

    let(:filepath) { @filepath }

    describe "#finish" do
      it "closes the filehandle" do
        expect(output.instance_variable_get(:"@output_io")).to receive(:close)
        output.finish
      end
    end

    describe "#handle_event" do
      before :each do
        output.handle_event(event)
      end
      specify "writes data to the path specified by :filename" do
        output.finish
        expect(File.read(@filepath)).not_to be_empty
      end
    end
  end

  describe "without specifying config.io or config.filename" do
    before :each do
      @orig_stdout = $stdout
      @duped_io = StringIO.new
      $stdout = double("stdout").as_null_object
      allow($stdout).to receive(:dup).and_return(@duped_io)
      @output = described_class.new(config)
    end

    let(:output) { @output }

    after :each do
      $stdout = @orig_stdout
    end

    it "uses a duplicate of $stdout" do
      expect($stdout).to have_received(:dup)
    end

    describe "#handle_event" do
      before :each do
        output.handle_event(event)
      end

      it "writes to the dupe of $stdout" do
        expect(@duped_io.string).not_to be_empty
      end
    end

    describe "#finish" do
      before :each do
        allow(@duped_io).to receive(:close).and_call_original
        output.finish
      end

      it "closes the dup of $stdout" do
        expect(@duped_io).to have_received(:close)
      end
    end

  end
end

