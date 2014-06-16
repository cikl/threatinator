require 'spec_helper'
require 'threatinator/io_wrappers/gzip'
require 'stringio'
require 'zlib'
require 'pp'

describe Threatinator::IOWrappers::Gzip do
  it_should_behave_like "an iowrapper" do
    let!(:input_data) {
      sio = StringIO.new
      gz = Zlib::GzipWriter.new(sio)
      gz.write(expected_data)
      gz.close
      sio.string
    }

    let(:expected_data) { 
      ret = ""
      '!'.upto('~') { |a| '!'.upto('~') { |b| ret << "#{a}#{b}" }  }
      ret
    }
  end
end

