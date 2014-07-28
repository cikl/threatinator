require 'threatinator/parsers/xml'
require 'threatinator/parsers/xml/path'

# Implements path matching behavior for use with the XML parser. Aims to support
# a small subset of XPath behaviors, specifically for matching elements. 
class Threatinator::Parsers::XML::Pattern
  # @param [String] pathspec A specification of a path match.
  def initialize(pathspec)
    parts = pathspec.split('/')
    leader_count = 0
    while parts[0] == ''
      leader_count += 1
      parts.shift
    end
    @path = Threatinator::Parsers::XML::Path.new(parts)
    @anchored = true

    if leader_count == 1
      @anchored = true
    elsif leader_count == 2
      @anchored = false
    else
      raise ArgumentError.new('pathspec must begin with "/" or "//"')
    end
  end

  def max_depth
    @anchored == true ? @path.length : Float::INFINITY
  end

  # @param [Threatinator::Parsers::XML::Path] path 
  # @return [Boolean] true if the pattern matches, false otherwise.
  def match?(path)
    if @anchored == true
      @path == path
    else 
      path.end_with?(@path)
    end
  end

  def _internal_data
    [@path, @anchored]
  end

  def ==(other)
    _internal_data == other._internal_data
  end
end
