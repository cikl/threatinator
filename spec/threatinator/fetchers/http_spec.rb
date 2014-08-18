require 'spec_helper'
require 'threatinator/fetchers/http'

describe Threatinator::Fetchers::Http do
    let(:url) { "http://foobar.com/bla.json" }
    let(:fetcher_builder) { lambda { described_class.new(url: url) } }
    let(:fetcher_builder_different) { lambda { described_class.new(url: "http://foobar.com/sdf.json") } }
    let(:fetcher) { fetcher_builder.call() }

  it_should_behave_like "a fetcher" do
    before :each do
      stub_request(:get, url).to_return(:body => expected_data)
    end
  end

  describe "#url" do
    it "should return the value of the URL" do
      expect(fetcher.url).to eq(url)
    end
  end

  [404, 500].each do |status_code|
    context "when an HTTP response has a status code of #{status_code}" do
      it_should_behave_like "a #fetch call that failed" do
        before :each do
          stub_request(:get, url)
            .to_return(:status => status_code)
        end
      end
    end
  end
end
