module Threatinator
  # Acts as a filter for parser data.
  class Filter
    # What is passed in as arguments depends upon the parser. 
    #
    # @param [Threatinator::Record] record The record to filter
    # @return [Boolean] true if filtered, false otherwise.
    def filter?(record)
      raise NotImplementedError.new("#{self.class}.filter?(record) not implemented")
    end
  end
end
