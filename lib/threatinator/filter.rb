module Threatinator
  # Acts as a filter for parser data.
  class Filter
    # What is passed in as arguments depends upon the parser. 
    #
    # @return [Boolean] true if filtered, false otherwise.
    def filter?(*args)
      raise NotImplementedError.new("#{self.class}.filter?(*args) not implemented")
    end
  end
end
