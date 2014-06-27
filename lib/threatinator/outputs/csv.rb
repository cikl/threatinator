require 'threatinator/output'
require 'csv'
module Threatinator
  module Outputs
    class CSV < Threatinator::Output
      def initialize(feed, output_io)
        super(feed, output_io)
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
          self.feed.provider,
          self.feed.name,
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
