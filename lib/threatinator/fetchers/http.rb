require 'threatinator/fetcher'
require 'threatinator/exceptions'
require 'threatinator/io_wrappers/simple'
require 'typhoeus'
require 'tempfile'

module Threatinator
  module Fetchers
    class Http < Threatinator::Fetcher
      # @param [Hash] opts An options hash. 
      # @option opts [Addressable::URI] :url The URL that is to be fetched 
      #   (required)
      #
      def initialize(opts = {})
        @url = opts.delete(:url) or raise ArgumentError.new("Missing :url")
        super(opts)
      end

      # @return [IO] an IO-style object.
      # @raise [Threatinator::Exceptions::FetchFailed] if the fetch fails
      def fetch
        tempfile = Tempfile.new("threatinator_http")
        request = Typhoeus::Request.new(@url, ssl_verifypeer: false)
        request.on_headers do |response|
          if response.response_code != 200

            raise Threatinator::Exceptions::FetchFailed.new("Request failed!")
          end
        end
        request.on_body do |chunk|
          tempfile.write(chunk)
        end
        # Run it
        request.run
        # Reset the IO to the beginning of the file
        tempfile.rewind
        return Threatinator::IOWrappers::Simple.new(tempfile)
      end
    end

  end
end
