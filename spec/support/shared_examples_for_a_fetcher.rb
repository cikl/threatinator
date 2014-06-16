require 'spec_helper'

shared_examples_for "a fetcher" do
  let(:expected_data) { "here's some data" }

  subject { fetcher }
  it { should respond_to(:fetch) }

  context "#fetch" do
    subject { fetcher.fetch }

    it { should be_kind_of(Threatinator::IOWrapper) }
    it "should return the expected data when #read" do
      expect(subject.read()).to eq(expected_data)
    end
  end
end

shared_examples_for "a #fetch call that failed" do
  it "should raise Threatinator::Exceptions::FetchFailed" do
    expect { fetcher.fetch() }.to raise_error(Threatinator::Exceptions::FetchFailed)
  end
end
