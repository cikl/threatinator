require 'spec_helper'
require 'threatinator/io_chain'
require 'threatinator/io_wrappers/rot13'
require 'threatinator/io_wrappers/downcase'
require 'stringio'

describe Threatinator::IOChain do
  let(:chain) do
    sio = StringIO.new(input_data)
    Threatinator::IOChain.new(sio)
  end

  context "processing a secret hacker message" do 
    let(:input_data) { "JR NE3 3YRRG UNK0EF!" }
    context "with no wrapper" do
      let(:expected_data) { input_data }

      it_should_behave_like "an io chain" 

      describe "#count" do
        subject { chain.count } 
        it { is_expected.to eq(1) }
      end

      context "#read" do
        subject { chain.read() }
        it {should eq(expected_data) }
      end
    end

    context "with rot13 and downcase wrappers" do
      let(:expected_data) { "we ar3 3leet hax0rs!" }
      before :each do
        chain.push(Threatinator::IOWrappers::Rot13)
        chain.push(Threatinator::IOWrappers::Downcase)
      end

      it_should_behave_like "an io chain" 

      describe "#count" do
        subject { chain.count } 
        it { is_expected.to eq(3) }
      end

    end
  end
end


