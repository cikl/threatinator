require 'active_model'
require 'active_model/validations'
require 'threatinator/model/validations'
require 'threatinator/exceptions'

module Threatinator
  module Model
    class Base
      include ActiveModel::Validations
      include Threatinator::Model::Validations

      def initialize
        validate!
      end

      def validate!
        unless valid?
          raise Threatinator::Exceptions::InvalidAttributeError, errors.full_messages.join("\n")
        end
      end
    end
  end
end
