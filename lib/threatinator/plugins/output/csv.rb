require 'threatinator/output'
require 'csv'
module Threatinator
  module Plugins
    module Output
      class Csv < Threatinator::FileBasedOutput
        class Config < superclass::Config
        end

        def initialize(config)
          super(config)
          @csv = ::CSV.new(self.output_io, 
                           :write_headers => true,
                           :headers => [
                             :provider,
                             :feed_name,
                             :type,
                             :ipv4_1,
                             :ipv4_2,
                             :ipv4_3,
                             :ipv4_4,
                             :fqdn_1,
                             :fqdn_2,
                             :fqdn_3,
                             :fqdn_4
                           ])
        end

        def handle_event(event)
          @csv.add_row([
            event.feed_provider,
            event.feed_name,
            event.type,
            event.ipv4s[0],
            event.ipv4s[1],
            event.ipv4s[2],
            event.ipv4s[3],
            event.fqdns[0],
            event.fqdns[1],
            event.fqdns[2],
            event.fqdns[3]
          ])
        end
      end
    end
  end
end
