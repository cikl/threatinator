require 'spec_helper'
require 'fetchers_shared'
require 'threatinator/fetchers/http'

describe Threatinator::Fetchers::Http do
  it_should_behave_like "a fetcher" do
    let(:fetcher) do
      url = "http://foobar.com/bla.json"
      stub_request(:get, url).to_return(:body => expected_data)
      described_class.new(:url => url)
    end
  end

  [404, 500].each do |status_code|
    context "when an HTTP response has a status code of #{status_code}" do
      it_should_behave_like "a #fetch call that failed" do
        let(:fetcher) do
          url = "http://foobar.com/bla.json"
          stub_request(:get, url)
            .to_return(:status => status_code)
          described_class.new(:url => url)
        end
      end
    end
  end
end
