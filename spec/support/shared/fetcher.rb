require 'spec_helper'

shared_examples_for "a fetcher" do
  let(:expected_data) { "here's some data" }

  subject { fetcher }
  it { should respond_to(:fetch) }

  it "should == itself" do
    expect(fetcher).to be == fetcher
  end

  it "should == an identically configured instance" do
    expect(fetcher_builder.call()).to be == fetcher_builder.call()
  end

  it "should not == a differently configured instance" do
    expect(fetcher_builder.call()).not_to be == fetcher_builder_different.call()
  end

  it "should eql?(itself)" do
    expect(fetcher).to eql(fetcher)
  end

  it "should eql? an identically configured instance" do
    expect(fetcher_builder.call()).to eql(fetcher_builder.call())
  end

  it "should not eql? an differently configured instance" do
    expect(fetcher_builder.call()).not_to eql(fetcher_builder_different.call())
  end

  context "the object returned by #fetch" do
    subject { fetcher.fetch }

    it_should_behave_like "an IO-like object"

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
