require 'spec_helper'
require 'tempfile'
require 'threatinator/plugin_loader'

shared_examples_for "an output plugin" do |name|
  # expects :output

  specify "the plugin loader should find the class by (#{name.inspect})" do
    loader = Threatinator::PluginLoader.new
    loader.load_plugins(:output)
    expect(loader[:output][name.to_sym]).to be(described_class)
  end

  describe "#finish" do
    it "should not raise any errors" do
      expect {
        output.finish()
      }.not_to raise_error
    end
  end

  describe "#handle_event" do
    let(:event) { build(:event) }
    it "should handle an event" do
      expect {
        output.handle_event(event)
      }.not_to raise_error
    end
  end
end

shared_examples_for "a file-based output plugin" do |name|
  let(:io) { StringIO.new } 
  let(:output) { described_class.new(io: io) }

  describe "#finish" do
    it "should close the underlying IO" do
      expect(io).not_to be_closed
      output.finish()
      expect(io).to be_closed
    end
  end

  describe "#handle_event" do
    let(:event) { build(:event) }
    it "should write some stuff out to the IO" do
      expect(io.string).to be_empty
      output.handle_event(event)
      expect(io.string).not_to be_empty
    end
  end

  describe "#initialize" do
    let(:event) { build(:event) }

    describe ":io => IO" do
      let(:io) { StringIO.new }
      let(:output) { described_class.new(io: io) }

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

    describe ":filename => String" do
      before :each do
        @tempfile = Tempfile.new("asdf")
        @tempfile.close
        @filepath = @tempfile.path
      end

      let(:filepath) { @filepath }
      let!(:output) { described_class.new(filename: filepath) }

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

    describe "no parameters" do
      before :each do
        @orig_stdout = $stdout
        @duped_io = StringIO.new
        $stdout = double("stdout").as_null_object
        allow($stdout).to receive(:dup).and_return(@duped_io)
      end

      after :each do
        $stdout = @orig_stdout
      end

      let!(:output) { described_class.new }

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
end

