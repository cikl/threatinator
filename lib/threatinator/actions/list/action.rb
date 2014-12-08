require 'threatinator/action'
require 'threatinator/exceptions'
require 'csv'
require 'multi_json'

module Threatinator
  module Actions
    module List
      class Action < Threatinator::Action
        def initialize(registry, config)
          super(registry)
          @config = config
        end

        def output_table(io_out)
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

        def output_json(io_out)
          feeds = []
          registry.each do |feed|
            info = {
              provider: feed.provider,
              name: feed.name,
              type: 'unknown',
              link: 'unknown'
            }
            fetcher = feed.fetcher_builder.call()
            case fetcher
            when Threatinator::Fetchers::Http
              info[:type] = "http"
              info[:link] = fetcher.url
            end

            feeds << info
          end
          feeds.sort! { |a,b| [a[:provider], a[:name]] <=> [b[:provider], b[:name]] }

          io_out.write(MultiJson.dump(feeds))
        end

        def exec
          case @config.format
          when 'table'
            output_table($stdout)
          when 'json'
            output_json($stdout)
          else
            raise ArgumentError, "Invalid argument for 'format' = '#{@config.format}'"
          end
        end
      end
    end
  end
end
