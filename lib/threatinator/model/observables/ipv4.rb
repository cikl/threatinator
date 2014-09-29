require 'threatinator/model/base'
require 'ip'
require 'equalizer'

module Threatinator
  module Model
    module Observables
      class Ipv4 < Threatinator::Model::Base
        include Equalizer.new(:ipv4)
        attr_reader :ipv4

        validates_each :ipv4 do |record, attr, value|
          if value.is_a?(::IP::V4)
            record.errors.add(attr, 'prefix length is not 32 bits') unless value.pfxlen == 32
          else
            record.errors.add(attr, 'not an IP::V4 object')
          end
        end

        # @param [Hash] opts
        # @option opts [IP::V4] :ipv4 An ipv4 object
        def initialize(opts = {})
          @ipv4 = opts.delete(:ipv4)
          super()
        end
      end
    end
  end
end

