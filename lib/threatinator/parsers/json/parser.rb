require 'threatinator/parser'
require 'threatinator/parsers/json/record'

module Threatinator
  module Parsers
    module JSON
      class Parser < Threatinator::Parser
        def initialize(opts = {})
          @adapter_class = self.class.adapter_class
          super(opts)
        end

        # Detects the platform, loads the JSON adapter, and returns the 
        # adapter's class.
        def self.adapter_class
          if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'
            #:nocov:
            raise "JSON parsing not supported for JRuby"
            #:nocov:
          else 
            require 'threatinator/parsers/json/adapters/oj'
            return Threatinator::Parsers::JSON::Adapters::Oj
          end
        end

        def ==(other)
          super(other)
        end

        # @param [IO] io
        # @yield [record] Gives one line to the block
        # @yieldparam record [Threatinator::Parsers::JSON::Record] a record
        def run(io)
          adapter = @adapter_class.new
          callback = lambda do |object, opts = {}|
            yield Threatinator::Parsers::JSON::Record.new(object, opts)
          end
          adapter.run(io, &callback)
          nil
        end

      end
    end
  end
end
