require 'spec_helper'
require 'threatinator/decoders/gzip'
require 'stringio'
require 'zlib'

describe Threatinator::Decoders::Gzip do
  let(:encode_data_proc) {
    lambda do |data|
      sio = StringIO.new
      sio.set_encoding("binary")
      gz = Zlib::GzipWriter.new(sio)
      gz.write(data)
      gz.close
      sio.string
    end
  }

  it_should_behave_like "a decoder" do
    let(:decoder_opts) { {} }
  end

  let(:uncompressed_data) { 
    ret = "".encode("binary")
    '!'.upto('~') { |a| '!'.upto('~') { |b| ret << "#{a}#{b}" }  }
    ret
  }

  let(:compressed_data) {
    encode_data_proc.call(uncompressed_data)
  }

  let(:decoder) { Threatinator::Decoders::Gzip.new }


  context "normal operation" do
    it "should decompress a Gzip compressed stream" do 
      encoded_io = StringIO.new(compressed_data)
      expect(decoder.decode(encoded_io).read).to eq(uncompressed_data)
    end
  end

  context "handling truncated data" do
    let(:truncated_data) {
      data = compressed_data
      data_len = data.length / 2
      data[0..(data_len - 1)]
    }

    it_should_behave_like "a decoder encountering an error during decoding" do
      let(:input_io) {StringIO.new(truncated_data)}
    end
  end

  context "handling a gzip stream with no footer" do
    let(:missing_footer_data) {
      compressed_data[0..-9] # knock off the footer, which is 8 bytes long
    }

    it_should_behave_like "a decoder encountering an error during decoding" do
      let(:input_io) {StringIO.new(missing_footer_data)}
    end
  end

  context "handling a gzip with an invalid footer" do
    let(:missing_footer_data) {
      ret = compressed_data
      ret[-9..-1] = "\0\0\0\0\0\0\0\0"
      ret
    }

    it_should_behave_like "a decoder encountering an error during decoding" do
      let(:input_io) { StringIO.new(missing_footer_data) }
    end
  end
end
