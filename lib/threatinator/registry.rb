require 'threatinator/exceptions'

module Threatinator
  # Just a simple class that holds stuff. Yup, a glorified hash.
  class Registry
    include Threatinator::Exceptions

    def initialize()
      @data= Hash.new
    end

    # @param [Object] key The object to use as the key for storing the object
    # @param [Object] object The object to be stored
    # @raise [Threatinator::Exceptions::dAlreadyRegisteredError] if an object
    #  with the same key is already registered.
    def register(key, object)
      if @data.has_key?(key)
        raise AlreadyRegisteredError.new(key)
      end
      @data[key] = object
    end

    # @param [Object] key 
    # @return [Object]
    def get(key)
      @data[key]
    end

    # @return [Array<Object>] an array of keys
    def keys
      @data.keys
    end

    # @return [Integer] the number of objects in the registry
    def count
      @data.count
    end

    # Enumerates through each object in our registry
    # @yield [object]
    # @yieldparam [Object] object An object within the registry
    def each(&block)
      return enum_for(:each) unless block_given?
      @data.each_pair(&block)
    end

    # Removes all objects from the registry
    def clear
      @data.clear
    end
  end
end

