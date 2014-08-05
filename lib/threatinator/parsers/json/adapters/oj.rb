require 'threatinator/parsers/json'
require 'threatinator/exceptions'
require 'oj'

module Threatinator::Parsers::JSON::Adapters
  class Oj < ::Oj::ScHandler
    def initialize
      @root = nil
      @depth = 0
    end

    def run(io, &callback)
      @callback = callback
      begin
        ::Oj.sc_parse(self, io)
      rescue ::Oj::ParseError => e
        raise Threatinator::Exceptions::ParseError.new(e)
      end
    end

    def do_callback(data, key = nil)
      @callback.call(data, key: key)
    end

    def hash_start
      ret = {}
      @depth += 1
      @root = ret if @root.nil?
      ret
    end

    def hash_set(h,k,v)
      if @depth == 1
        do_callback(v, k)
      else 
        h[k] = v
      end
      v
    end

    def hash_end
      @depth -= 1
    end

    def array_start
      ret = []
      @depth += 1
      @root = ret if @root.nil?
      ret
    end

    def array_append(a,v)
      if @depth == 1
        do_callback(v)
      else 
        a << v
      end
    end

    def array_end
      @depth -= 1
    end
  end
end

