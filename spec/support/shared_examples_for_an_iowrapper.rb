require 'spec_helper'
require 'stringio'

shared_examples_for "an iowrapper" do

  # The real IO object that is ultimately wrapped.
  let(:source_io) { StringIO.new(input_data) }

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
    it "should read data from the wrapped io object" do
      expect(io_wrapper.read()).to eq(expected_data)
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
