require 'threatinator/config/base'

module Threatinator
  module Config
    class FeedSearch < Threatinator::Config::Base
      DEFAULT_FEED_PATH = File.expand_path("../../../../feeds", __FILE__)

      attribute :exclude_default, Boolean, default: false, 
        description: 'Exclude default path from feed search path'

      attribute :path, Array[String],
        description: 'The paths to search for feeds'

      # @return [Array<String>] An array of paths to search
      def search_path
        ret = self.path
        if self.exclude_default == false
          ret = ret + [DEFAULT_FEED_PATH]
        end
        ret
      end
    end
  end
end

