require 'threatinator/record'
require 'threatinator/parsers/xml'

class Threatinator::Parsers::XML::Record < Threatinator::Record
  alias_method :node, :data
  def initialize(node, opts = {})
    super(node, opts)
  end
end
