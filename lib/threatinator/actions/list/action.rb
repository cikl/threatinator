require 'threatinator/action'
require 'threatinator/exceptions'
require 'csv'

module Threatinator
  module Actions
    module List
      class Action < Threatinator::Action
        def initialize(registry, config)
          super(registry)
          @config = config
        end

        def exec
          io_out = $stdout
          feed_info = [['provider', 'name', 'type', 'link/path']]
          registry.each do |feed|
            info = [ feed.provider, feed.name ]
            fetcher = feed.fetcher_builder.call()
            type = "unknown"
            link = "unknown"
            case fetcher
            when Threatinator::Fetchers::Http
              type = "http"
              link = fetcher.url
            end
            info << type
            info << link
            feed_info << info
          end
          return if feed_info.count == 0
          fmts = []
          widths = []
          0.upto(3) do |i|
            max = feed_info.max { |a,b| a[i].length <=> b[i].length }[i].length
            widths << max
            fmts << "%#{max}s"
          end
          fmt = "%-#{widths[0]}s  %-#{widths[1]}s  %-#{widths[2]}s  %-#{widths[3]}s\n"
          io_out.printf(fmt, *(feed_info.shift))
          sep = widths.map {|x| '-' * x }
          io_out.printf(fmt, *sep)
          feed_info.sort! { |a,b| [a[0], a[1]] <=> [b[0], b[1]] }
          feed_info.each  do |info|
            io_out.printf(fmt, *info)
          end
          io_out.printf(fmt, *sep)
          io_out.puts("Total: #{feed_info.count}")
        end
      end
    end
  end
end
