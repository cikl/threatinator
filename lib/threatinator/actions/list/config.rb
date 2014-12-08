require 'threatinator/config/base'

module Threatinator
  module Actions
    module List
      class Config < Threatinator::Config::Base
        attribute :format, String, default: lambda { |c,a| 'table' },
          description: "The format in which to generate output: 'table' (default), 'json'"
      end
    end
  end
end
