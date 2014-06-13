require 'spec_helper'

shared_examples_for "a fetcher" do
  let(:expected_data) { "here's some data" }

  subject { fetcher }
  it { should respond_to(:fetch) }

  context "#fetch" do
    subject { fetcher.fetch }

    it { should be_kind_of(Threatinator::IOWrapperMixin) }
    it "should return the expected data when #read" do
      expect(subject.read()).to eq(expected_data)
    end
    it "should close the underlying io object when #close is called" do
      expect(subject.to_io()).not_to be_closed
      subject.close()
      expect(subject.to_io()).to be_closed
    end
  end
end

shared_examples_for "a #fetch call that failed" do
  it "should raise Threatinator::Exceptions::FetchFailed" do
    expect { fetcher.fetch() }.to raise_error(Threatinator::Exceptions::FetchFailed)
  end
end
