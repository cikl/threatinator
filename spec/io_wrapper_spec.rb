require 'spec_helper'
require 'threatinator/io_wrapper'

describe Threatinator::IOWrapper do

  describe :wrap do
    it "should return an IOWrapper for the IO object" do
    end
  end

  context "an instance" do
    let(:expected_data) { "here's some data" }
    let(:wrapped_io) { 
      r, w = IO.pipe()
      w.write(expected_data)
      w.close
      r
    }
    let!(:io_wrapper) { described_class.wrap(wrapped_io) }

    after :each do
      io_wrapper.close rescue nil
      wrapped_io.close rescue nil
    end

    describe "#to_io" do
      it "should return the the wrapped IO object" do
        expect(io_wrapper.to_io).to be(wrapped_io)
      end
    end

    describe "#close" do
      it "should close the wrapped IO object" do
        expect(wrapped_io).not_to be_closed
        io_wrapper.close
        expect(wrapped_io).to be_closed
      end
    end

    describe "#read" do
      it "should read data from the wrapped IO object" do
        expect(io_wrapper.read()).to eq(expected_data)
      end
      it "should raise an IOError if the wrapped IO is closed" do
        wrapped_io.close
        expect { io_wrapper.read() }.to raise_error(IOError)
      end
      it "should raise an IOError if #close was called before #read is called" do
        io_wrapper.close
        expect { io_wrapper.read() }.to raise_error(IOError)
      end
    end
  end
end
