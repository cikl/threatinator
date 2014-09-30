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
                             :fqdn_4,
                             :url_1,
                             :url_2,
                             :url_3,
                             :url_4
                           ])
        end

        def handle_event(event)
          ipv4s = event.ipv4s.to_a[0..3].map { |o| o.nil? ? nil : o.ipv4.to_addr }
          fqdns = event.fqdns.to_a[0..3]
          urls  = event.urls.to_a[0..3].map {|x| x.to_s }
          @csv.add_row([
            event.feed_provider,
            event.feed_name,
            event.type,
            ipv4s[0],
            ipv4s[1],
            ipv4s[2],
            ipv4s[3],
            fqdns[0],
            fqdns[1],
            fqdns[2],
            fqdns[3],
            urls[0],
            urls[1],
            urls[2],
            urls[3],
          ])
        end
      end
    end
  end
end
