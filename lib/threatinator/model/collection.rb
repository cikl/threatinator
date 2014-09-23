require 'threatinator/exceptions'
require 'set'

module Threatinator
  module Model
    class Collection
      def initialize(values = [])
        @collection = Set.new
        values.each do |v|
          self << v
        end
      end

      def valid_member?(v)
        #:nocov:
        raise NotImplementedError, "#valid_member? not implemented"
        #:nocov:
      end

      def <<(v)
        unless valid_member?(v)
          raise Threatinator::Exceptions::InvalidAttributeError, "Invalid member: #{v.class} '#{v.inspect}'"
        end
        @collection << v
      end

      def include?(member)
        @collection.include?(member)
      end

      # @return [Boolean] true if empty, false otherwise
      def empty?
        @collection.empty?
      end

      # @return [Integer] the number of members in the collection
      def count
        @collection.count
      end

      def to_ary
        @collection.to_a
      end
      alias_method :to_a, :to_ary

      def each
        return to_enum(:each) unless block_given?
        @collection.each { |v| yield v }
      end

      def ==(other)
        if self.equal?(other)
          return true
        elsif other.instance_of?(self.class)
          @collection == other.instance_variable_get(:@collection)
        else
          false
        end
      end

    end

  end
end
