module Threatinator
  module Parsers
    module XML
      class Node
        attr_accessor :text
        attr_reader :name
        attr_reader :attrs
        attr_reader :children

        # @param [String, Symbol] name
        # @param [Hash] opts 
        # @option opts [String] :text The text
        # @option opts [Hash] :attrs The attributes
        # @option opts [Array<Threatinator::Parsers::XML::Node>] :children An array 
        #   of child child nodes that belong to this node.
        def initialize(name, opts = {})
          unless name.kind_of?(::Symbol) or name.kind_of?(::String)
            raise TypeError.new("name must be a String or a Symbol")
          end

          @name = name.to_sym
          @text = opts.delete(:text) || ""
          unless @text.kind_of?(::String)
            raise TypeError.new(":text must be a String")
          end
          @attrs = opts.delete(:attrs) || {}
          unless @attrs.kind_of?(::Hash)
            raise TypeError.new(":text must be a Hash")
          end

          @children = {}
          if _children = opts.delete(:children)
            _children.each do |child|
              add_child(child)
            end
          end
        end

        def ==(other)
          @name == other.name &&
            @attrs == other.attrs &&
            @text == other.text &&
            @children == other.children
        end

        def eql?(other)
          other.kind_of?(self.class) &&
            self == other
        end

        # @return [Integer] the number of children
        def num_children
          @children.values.inject(0) {|total, child_set| total + child_set.count}
        end

        # @param [String, Symbol] name The name of the child element
        # @return [Array<Node>] An array containing all the child nodes for the given
        #  name. The array will be empty if there are no children by the given name.
        def [](name)
          @children[name.to_sym] || []
        end

        # @return [Array<Symbol>] an array containing all the names of child elements
        def child_names
          @children.keys
        end

        private
        def add_child(child)
          name = child.name
          unless child_set = @children[name]
            child_set = @children[name] = []
          end
          child_set << child
        end
      end
    end
  end
end
