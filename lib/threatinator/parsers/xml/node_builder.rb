require 'threatinator/parsers/xml'
require 'threatinator/parsers/xml/node'

class Threatinator::Parsers::XML::NodeBuilder
  def initialize(name, attributes)
    @name = name
    @attributes = {}
    @children = []
    @text = ""

    unless attributes.empty?
      attributes.each { |attr| self.add_attribute(attr.localname, attr.value) }
    end
  end

  def append_text(chars)
    @text << chars
  end

  def add_attribute(name, value)
    @attributes[name.to_sym] = value
  end

  def add_child(node)
    @children << node
  end

  def build
    Threatinator::Parsers::XML::Node.new(@name, 
                                         attrs: @attributes, 
                                         text: @text.strip, 
                                         children: @children)
  end
end
