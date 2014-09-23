require 'threatinator/model/collection'
require 'addressable/uri'

module Threatinator
  module Model
    module Observables
      class UrlCollection < Threatinator::Model::Collection
        def valid_member?(v)
          v.is_a?(::Addressable::URI) &&
            v.absolute?
        end
      end
    end
  end
end

