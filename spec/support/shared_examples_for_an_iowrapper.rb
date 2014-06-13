require 'spec_helper'
  shared_examples_for "an iowrapper" do
    it_should_behave_like "an iowrapper instance"

    describe "when wrapping an IOWrapper object" do
      it_should_behave_like "an iowrapper instance" do
        let(:wrapped_io) { 
          Threatinator::IOWrapper.new(real_io_object)
        }
      end
    end
  end

  shared_examples_for "an iowrapper instance" do
    let(:input_data)    { "here's some data" }
    let(:expected_data) { input_data }

    # The real IO object that is ultimately wrapped.
    let(:real_io_object) { 
      r, w = IO.pipe()
      w.write(input_data)
      w.close
      r
    }

    # The IO or IOWrapper that is wrapped by 'io_wrapper'. This is just so that
    # we can test that the described_class can operate on wrapped IO objects,
    # as well as real IO objects. 
    let(:wrapped_io) { real_io_object }
    let!(:io_wrapper) { described_class.wrap(wrapped_io) }

    after :each do
      io_wrapper.close rescue nil
      real_io_object.close rescue nil
    end

    describe "#to_io" do
      it "should return the the real io object" do
        expect(io_wrapper.to_io).to be(real_io_object)
      end
    end

    describe "#close" do
      it "should close the real io object" do
        expect(real_io_object).not_to be_closed
        io_wrapper.close
        expect(real_io_object).to be_closed
      end

      it "should close the wrapped io object" do
        expect(wrapped_io).not_to be_closed
        io_wrapper.close
        expect(wrapped_io).to be_closed
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

    describe "#read" do
      it "should read data from the wrapped io object" do
        expect(io_wrapper.read()).to eq(expected_data)
      end
      it "should raise an IOError if the real io object is closed" do
        real_io_object.close
        expect { io_wrapper.read() }.to raise_error(IOError)
      end
      it "should raise an IOError if #close was called before #read is called" do
        io_wrapper.close
        expect { io_wrapper.read() }.to raise_error(IOError)
      end
    end
  end
