require 'spec_helper'
require 'stringio'

shared_examples_for "an iowrapper" do

  # The real IO object that is ultimately wrapped.
  let(:source_io) { Threatinator::IOWrapper.new(StringIO.new(input_data)) }

  let!(:io_wrapper) { described_class.new(source_io) }

  after :each do
    io_wrapper.close rescue nil
  end

  describe "#close" do
    it "should close the real io object" do
      expect(source_io).not_to be_closed
      io_wrapper.close
      expect(source_io).to be_closed
    end

    it "should close the io wrapper object" do
      expect(io_wrapper).not_to be_closed
      io_wrapper.close
      expect(io_wrapper).to be_closed
    end
  end

  describe "#closed?" do
    it "should return true if the io is closed" do
      io_wrapper.close
      expect(io_wrapper).to be_closed
    end
    it "should return false if the io is not closed" do
      expect(io_wrapper).not_to be_closed
    end
  end

  describe "#eof?" do
    it "should be false if we haven't read anything" do
      expect(io_wrapper.eof?).to eq(false)
    end

    it "should be true if we've read everything" do
      io_wrapper.read()
      expect(io_wrapper.eof?).to eq(true)
    end
  end

  describe "#read" do
    context "(no arguments)" do
      it "should read all data" do
        expect(io_wrapper.read()).to eq(expected_data)
      end

      # Per the ruby spec http://ruby-doc.org/core-1.9.3/IO.html#method-i-read
      it "should return an empty string if there is no more data to read" do
        expect(io_wrapper.read()).to eq(expected_data)
        expect(io_wrapper.read()).to eq("")
      end
    end

    context "with a read length argument" do
      it "should read all data if the read length is nil" do
        expect(io_wrapper.read(nil)).to eq(expected_data)
      end

      it "should read no more than the number of characters than the read length specifies" do
        read_length = expected_data.length - 1
        raise "expected_data string is too short! must be at least 2 characters" if read_length == 0
        expect(io_wrapper.read(read_length)).to eq(expected_data[0..-2])
      end

      it "should read at most the number of characters in the IO, even if that's less than read_length" do
        expect(io_wrapper.read(expected_data.length * 2)).to eq(expected_data)
      end

      # Per the ruby spec http://ruby-doc.org/core-1.9.3/IO.html#method-i-read
      it "should return nil if there is no more data to read" do
        expect(io_wrapper.read()).to eq(expected_data)
        expect(io_wrapper.read(1)).to be_nil
      end
    end

    it "should raise an IOWrapperError if it has to read from a closed IO" do
      source_io.close
      expect { 
        io_wrapper.read() 
      }.to raise_error(Threatinator::Exceptions::IOWrapperError)
    end

    it "should raise an IOWrapperError if #close was called before #read is called" do
      io_wrapper.close
      expect { io_wrapper.read() }.to raise_error(Threatinator::Exceptions::IOWrapperError)
    end

  end
end
