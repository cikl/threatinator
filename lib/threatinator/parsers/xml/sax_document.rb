require 'threatinator/parsers/xml/node_builder'
require 'threatinator/parsers/xml/path'
require 'nokogiri'

module Threatinator
  module Parsers
    module XML
      class SAXDocument < Nokogiri::XML::SAX::Document
        def initialize(pattern, cb)
          @pattern = pattern
          @max_depth = @pattern.max_depth
          @cb = cb
          @element_stack = Threatinator::Parsers::XML::Path.new
          @parsing_stack = []
          @current_node = nil
          super()
        end

        def start_parsing(name, attributes)
          @current_node = Threatinator::Parsers::XML::NodeBuilder.new(name, attributes)
          @parsing_stack.push(@current_node)
        end

        def characters(str)
          return if @current_node.nil?
          @current_node.append_text(str)
        end

        alias_method :cdata_block, :characters

        def start_element_namespace(name, attrs = [], prefix = nil, uri = nil, ns = [])
          @element_stack.push(name)

          if @parsing_stack.empty?
            if @element_stack.length > @max_depth
              return
            end

            if @pattern.match?(@element_stack)
              start_parsing(name, attrs)
            end
          else
            start_parsing(name, attrs)
          end
        end

        def end_element_namespace(name, prefix = nil, uri = nil)
          name_sym = name.to_sym
          @element_stack.pop
          return if @parsing_stack.empty?
          @parsing_stack.pop

          if parent = @parsing_stack.last
            parent.add_child(@current_node.build)
            @current_node = parent
          else
            @cb.call(@current_node.build)
            @current_node = nil
          end
        end
      end
    end
  end
end
