require 'virtus'
module Threatinator
  module Config
    class Base
      include Virtus.model

      def self.properties(namespace = nil)
        ret = {}
        self.attribute_set.each do |attribute|
          name = attribute.name.to_s
          unless namespace.nil?
            name = [namespace, name].join('.')
          end

          if attribute.primitive.ancestors.include?(Threatinator::Config::Base)
            ret.merge!(attribute.primitive.properties(name))
            next
          end

          desc = attribute.options[:description]
          case desc
          when nil
            next
          when ::Proc
            desc = desc.call(self, attribute)
          end 
          ret[name] = [desc, attribute.type]
        end
        ret
      end
    end

  end
end

