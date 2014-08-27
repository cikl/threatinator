require 'threatinator/cli/action_builder'
require 'threatinator/actions/list'

module Threatinator
  module CLI
    class ListActionBuilder < ActionBuilder
      def build
        Threatinator::Actions::List::Action.new(feed_registry, config)
      end

      def config
        list_hash = config_hash["list"] || {}
        Threatinator::Actions::List::Config.new(list_hash)
      end

    end
  end
end

