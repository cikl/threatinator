# encoding: utf-8
require 'spec_helper'
require 'threatinator/exceptions'

shared_examples_for "a decoder" do
  # Expects :encode_data_proc, :decoder_opts
  let(:extra_opts) { { } }
  let(:decoder) { described_class.new(decoder_opts.merge(extra_opts)) }

  describe "an instance" do
    subject { decoder }
    it { is_expected.to respond_to(:decode) }

    it "should close the IO that it decodes from" do
      data = encode_data_proc.call("here's some data")
      io = StringIO.new(data)
      expect(io).not_to be_closed
      decoder.decode(io)
      expect(io).to be_closed
    end

  end

  describe "decoding a UTF-8 string" do 
    let(:original_string) { 
      "\xE1\x9A\xA0\xE1\x9B\x87\xE1\x9A\xBB\xE1\x9B\xAB\xE1\x9B\x92\xE1\x9B\xA6\xE1\x9A\xA6\xE1\x9B\xAB\xE1\x9A\xA0\xE1\x9A\xB1\xE1\x9A\xA9\xE1\x9A\xA0\xE1\x9A\xA2\xE1\x9A\xB1\xE1\x9B\xAB\xE1\x9A\xA0\xE1\x9B\x81\xE1\x9A\xB1\xE1\x9A\xAA\xE1\x9B\xAB\xE1\x9A\xB7\xE1\x9B\x96\xE1\x9A\xBB\xE1\x9A\xB9\xE1\x9B\xA6\xE1\x9B\x9A\xE1\x9A\xB3\xE1\x9A\xA2\xE1\x9B\x97\n\xE1\x9B\x8B\xE1\x9A\xB3\xE1\x9B\x96\xE1\x9A\xAA\xE1\x9B\x9A\xE1\x9B\xAB\xE1\x9A\xA6\xE1\x9B\x96\xE1\x9A\xAA\xE1\x9A\xBB\xE1\x9B\xAB\xE1\x9B\x97\xE1\x9A\xAA\xE1\x9A\xBE\xE1\x9A\xBE\xE1\x9A\xAA\xE1\x9B\xAB\xE1\x9A\xB7\xE1\x9B\x96\xE1\x9A\xBB\xE1\x9A\xB9\xE1\x9B\xA6\xE1\x9B\x9A\xE1\x9A\xB3\xE1\x9B\xAB\xE1\x9B\x97\xE1\x9B\x81\xE1\x9A\xB3\xE1\x9B\x9A\xE1\x9A\xA2\xE1\x9A\xBE\xE1\x9B\xAB\xE1\x9A\xBB\xE1\x9B\xA6\xE1\x9B\x8F\xE1\x9B\xAB\xE1\x9B\x9E\xE1\x9A\xAB\xE1\x9B\x9A\xE1\x9A\xAA\xE1\x9A\xBE\n\xE1\x9A\xB7\xE1\x9B\x81\xE1\x9A\xA0\xE1\x9B\xAB\xE1\x9A\xBB\xE1\x9B\x96\xE1\x9B\xAB\xE1\x9A\xB9\xE1\x9B\x81\xE1\x9B\x9A\xE1\x9B\x96\xE1\x9B\xAB\xE1\x9A\xA0\xE1\x9A\xA9\xE1\x9A\xB1\xE1\x9B\xAB\xE1\x9B\x9E\xE1\x9A\xB1\xE1\x9B\x81\xE1\x9A\xBB\xE1\x9B\x8F\xE1\x9A\xBE\xE1\x9B\x96\xE1\x9B\xAB\xE1\x9B\x9E\xE1\x9A\xA9\xE1\x9B\x97\xE1\x9B\x96\xE1\x9B\x8B\xE1\x9B\xAB\xE1\x9A\xBB\xE1\x9B\x9A\xE1\x9B\x87\xE1\x9B\x8F\xE1\x9A\xAA\xE1\x9A\xBE\xE1\x9B\xAC\n"
      .force_encoding("UTF-8")
    }

    let(:encoded_string) { encode_data_proc.call(original_string) }
    let(:encoded_io) { StringIO.new(encoded_string) }

    describe "the decoded data" do
      it "should equal the original string" do
        expect(decoder.decode(encoded_io).read()).to eq(original_string)
      end
      it "should be UTF-8 encoded" do
        expect(decoder.decode(encoded_io).read().encoding).to eq(Encoding::UTF_8)
      end
    end
  end

  describe "decoding a UTF-8 string2" do 
    let(:original_string) { 
      "21826        |  Corporación Telemic C.A.,VE    |    200.75.105.49  |  2014-07-18 19:54:54  |  sshpwauth".force_encoding("UTF-8")
    }

    let(:encoded_string) { encode_data_proc.call(original_string) }
    let(:encoded_io) { StringIO.new(encoded_string) }

    describe "the decoded data" do
      it "should equal the original string" do
        expect(decoder.decode(encoded_io).read()).to eq(original_string)
      end
      it "should be UTF-8 encoded" do
        expect(decoder.decode(encoded_io).read().encoding).to eq(Encoding::UTF_8)
      end
    end
  end
end

shared_examples_for "a decoder encountering an error during decoding" do
  # Expects :decoder, :input_io
  it "#decode should raise a DecoderError" do
    expect { 
      decoder.decode(input_io)
    }.to raise_error(Threatinator::Exceptions::DecoderError)
  end
end

