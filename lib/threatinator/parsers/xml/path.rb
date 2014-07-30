require 'threatinator/parsers/xml'

class Threatinator::Parsers::XML::Path
  attr_reader :parts

  # @param [String, Array, nil] str_or_parts ([]) If set to a String, splits 
  #   the string by '/' into an array. If set to an Array, sets parts to a
  #   duplicate of the array. If set to nil or not specified, defaults to 
  #   a new array.
  # @raise [TypeError] if something other than a String, Array, or nil is 
  #   specified for str_or_parts.
  def initialize(str_or_parts = nil)
    @parts = 
      case str_or_parts
      when ::String
        if str_or_parts.length == 0 or !str_or_parts.start_with?('/')
          raise ArgumentError.new('str_or_parts must be a String beginning with "/"')
        end
        r = str_or_parts.split('/')
        r.shift
        r
      when ::Array
        str_or_parts.dup
      when nil
        []
      else
        raise TypeError.new("Expected argument must be a String, Array, or nil")
      end
  end

  def ==(other)
    @parts == other.parts
  end

  def eql?(other)
    other.kind_of?(self.class) &&
      self == other
  end

  # length = 5
  #   0 1 2 3 4
  #  /a/b/c/d/e
  #         0 1
  #        /d/e
  def end_with?(other_path)
    return false if other_path.length > self.length
    return true if other_path.length == 0
    pos = length - other_path.length
    other_path.parts.each_with_index do |other_part, idx|
      return false unless @parts[(pos + idx)] == other_part
    end
    true
  end

  def push(name)
    @parts.push(name)
  end

  def pop
    @parts.pop
  end

  def length
    @parts.length
  end
end

