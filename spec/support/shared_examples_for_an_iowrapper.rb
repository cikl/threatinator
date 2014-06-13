require 'spec_helper'
  shared_examples_for "an iowrapper" do
    it_should_behave_like "an iowrapper instance"

    describe "when wrapping an existing IO Wrapper" do
      it_should_behave_like "an iowrapper instance" do
        let(:wrapped_io) { 
          r, w = IO.pipe()
          w.write(expected_data)
          w.close
          Threatinator::IOWrapper.new(r)
        }
      end
    end
  end

  shared_examples_for "an iowrapper instance" do
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
      wrapped_io.to_io.close rescue nil
    end

    describe "#to_io" do
      it "should return the the wrapped io object" do
        expect(io_wrapper.to_io).to be(wrapped_io.to_io)
      end
    end

    describe "#close" do
      it "should close the wrapped io object" do
        expect(wrapped_io.to_io).not_to be_closed
        io_wrapper.close
        expect(wrapped_io.to_io).to be_closed
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

    describe "#read" do
      it "should read data from the wrapped io object" do
        expect(io_wrapper.read()).to eq(expected_data)
      end
      it "should raise an IOError if the wrapped io is closed" do
        wrapped_io.to_io.close
        expect { io_wrapper.read() }.to raise_error(IOError)
      end
      it "should raise an IOError if #close was called before #read is called" do
        io_wrapper.close
        expect { io_wrapper.read() }.to raise_error(IOError)
      end
    end
  end
