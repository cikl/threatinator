require 'active_model'
require 'active_model/validations'

module Threatinator
  module Model
    module Validations
      class TypeValidator < ActiveModel::EachValidator
        def initialize(options)
          @type = options.delete(:with)
          super
        end

        def validate_each(record, name, value)
          unless value.is_a?(@type)
            record.errors.add name, "Expected to be #{@type}, got #{value.class} #{value.inspect}"
          end
        end
      end
    end
  end
end 
