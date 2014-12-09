require 'threatinator/fetcher'
require 'threatinator/exceptions'
require 'typhoeus'
require 'tempfile'

module Threatinator
  module Fetchers
    class Http < Threatinator::Fetcher
      attr_reader :url
      # @param [Hash] opts An options hash. 
      # @option opts [Addressable::URI] :url The URL that is to be fetched 
      #   (required)
      #
      def initialize(opts = {})
        @url = opts.delete(:url) or raise ArgumentError.new("Missing :url")
        super(opts)
      end

      def ==(other)
        @url == other.url && super(other)
      end

      # @return [IO] an IO-style object.
      # @raise [Threatinator::Exceptions::FetchFailed] if the fetch fails
      def fetch
        tempfile = Tempfile.new("threatinator_http")
        request = Typhoeus::Request.new(@url, 
                                        ssl_verifypeer: false, 
                                        forbid_reuse: true
                                       )
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
        tempfile
      end
    end

  end
end
