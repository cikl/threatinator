require 'threatinator/entry'

module Threatinator
  class EntryBuilder
    def initialize(output = nil)
      @output = output
    end

    def create_entry
      entry = Threatinator::Entry.new
      yield(entry)
    end
  end
end

