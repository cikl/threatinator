require 'spec_helper'
require 'threatinator/io_wrappers/gzip'
require 'stringio'
require 'zlib'
require 'pp'

describe Threatinator::IOWrappers::Gzip do
  let(:uncompressed_data) { 
    ret = "".encode("binary")
    '!'.upto('~') { |a| '!'.upto('~') { |b| ret << "#{a}#{b}" }  }
    ret
  }

  let(:compressed_data) {
    sio = StringIO.new
    sio.set_encoding("binary")
    gz = Zlib::GzipWriter.new(sio)
    gz.write(uncompressed_data)
    gz.close
    sio.string
  }

  it_should_behave_like "an iowrapper" do
    let!(:input_data) {
      compressed_data
    }

    let(:expected_data) { uncompressed_data }
  end

  context "handling truncated data" do
    let(:truncated_data) {
      data = compressed_data
      data_len = data.length / 2
      data[0..(data_len - 1)]
    }

    let(:source_io) {
      StringIO.new(truncated_data.encode("binary"))
    }

    let(:io_wrapper) { described_class.new(source_io) }

    describe "#read" do
      it "should raise an IOWrapperError" do
        expect { io_wrapper.read() }.to raise_error(Threatinator::Exceptions::IOWrapperError)
      end
    end
  end

  context "handling a gzip stream with no footer" do
    let(:missing_footer_data) {
      compressed_data[0..-9] # knock off the footer, which is 8 bytes long
    }

    let(:source_io) {
      StringIO.new(missing_footer_data.encode("binary"))
    }

    let(:io_wrapper) { described_class.new(source_io) }


    describe "#read(1)" do
      it "should not raise an error" do
        expect { io_wrapper.read(1) }.not_to raise_error
      end
    end

    describe "#read()" do
      it "should raise an IOWrapperError" do
        expect { io_wrapper.read() }.to raise_error(Threatinator::Exceptions::IOWrapperError)
      end
    end

    describe "#read(data_len * 2)" do
      it "should raise an IOWrapperError" do
        expect { io_wrapper.read(uncompressed_data.length * 2) }.to raise_error(Threatinator::Exceptions::IOWrapperError)
      end
    end
  end

  context "handling a gzip with an invalid footer" do
    let(:missing_footer_data) {
      ret = compressed_data
      ret[-9..-1] = "\0\0\0\0\0\0\0\0"
      ret
    }

    let(:source_io) {
      StringIO.new(missing_footer_data.encode("binary"))
    }

    let(:io_wrapper) { described_class.new(source_io) }

    describe "#read(1)" do
      it "should not raise an error" do
        expect { io_wrapper.read(1) }.not_to raise_error
      end
    end

    describe "#read()" do
      it "should raise an IOWrapperError" do
        expect { io_wrapper.read() }.to raise_error(Threatinator::Exceptions::IOWrapperError)
      end
    end

    describe "#read(data_len * 2)" do
      it "should raise an IOWrapperError" do
        expect { io_wrapper.read(uncompressed_data.length * 2) }.to raise_error(Threatinator::Exceptions::IOWrapperError)
      end
    end
  end
end

