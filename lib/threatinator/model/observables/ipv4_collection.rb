require 'threatinator/model/collection'
require 'threatinator/model/observables/ipv4'

module Threatinator
  module Model
    module Observables
      class Ipv4Collection < Threatinator::Model::Collection
        def valid_member?(v)
          v.kind_of?(Threatinator::Model::Observables::Ipv4)
        end
      end
    end
  end
end
