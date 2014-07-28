require 'spec_helper'
require 'threatinator/parsers/xml/node'
require 'set'

describe Threatinator::Parsers::XML::Node do
  describe "initializing" do
    describe "name" do
      context "when a symbol is provided" do
        specify "the name is the symbol" do
          node = described_class.new(:foobar)
          expect(node.name).to be(:foobar)
        end
      end
      context "when a string is provided" do
        specify "the name is the symbolized version of the string" do
          node = described_class.new("foobar")
          expect(node.name).to be(:foobar)
        end
      end
      context "when it is neither a string nor a symbol" do
        it "raises a TypeError" do
          expect { described_class.new(Object.new) }.to raise_error(TypeError)
        end
      end
    end

    describe ":text" do
      context "when a string" do
        specify "the text is the string" do
          node = described_class.new(:foo, text: "hey there big boy")
          expect(node.text).to eq("hey there big boy")
        end
      end

      context "when nil" do
        specify "the text is an empty string" do
          node = described_class.new(:foo, text: nil)
          expect(node.text).to eq("")
        end
      end

      context "when not provided" do
        specify "the text is an empty string" do
          node = described_class.new(:foo)
          expect(node.text).to eq("")
        end
      end
      context "when something other than a string or nil" do
        it "raises a TypeError" do
          expect { described_class.new(:foo, text: Object.new) }.to raise_error(TypeError)
        end
      end
    end

    describe ":attrs" do
      context "when not provided" do
        specify "the attrs are an empty hash" do
          node = described_class.new(:foo)
          expect(node.attrs).to eq({})
        end
      end
      context "when nil" do
        specify "the attrs are an empty hash" do
          node = described_class.new(:foo, attrs: nil)
          expect(node.attrs).to eq({})
        end
      end
      context "when a hash of attributes" do
        specify "the attrs are the provided attributes" do
          node = described_class.new(:foo, attrs: {foo: "asdf", bar: "123"})
          expect(node.attrs).to eq({foo:"asdf", bar:"123"})
        end
      end
      context "when something other than a hash or nil" do
        it "raises a TypeError" do
          expect { described_class.new(:foo, attrs: Object.new) }.to raise_error(TypeError)
        end
      end
    end

    describe ":children" do
      context "when not provided" do
        specify "it should have no children" do
          node = described_class.new(:foo)
          expect(node.children).to eq({})
        end
      end

      context "when nil" do
        specify "it should have no children" do
          node = described_class.new(:foo, children: nil)
          expect(node.children).to eq({})
        end
      end

      context "when a collection of Nodes" do
        specify "it should have all those nodes as children" do
          children = build_list(:xml_node, 20, name: :bla)
          node = described_class.new(:foo, children: children)
          expect(node.num_children).to eq(20)
          expect(node[:bla]).to match_array(children)
        end
      end
    end
  end

  describe "#==" do
    it "returns true when compared to itself" do
      node = build(:xml_node)
      expect(node).to be == node
    end

    it "returns true when compared an identically configured node" do
      node1 = build(:xml_node)
      node2 = build(:xml_node)
      expect(node1).to be == node2
    end

    it "returns true when compared to an object that looks like the node" do
      node1 = build(:xml_node)
      node2 = build(:xml_node)
      fake_node_class = Struct.new(:name, :attrs, :text, :children)
      fake_node = fake_node_class.new(node2.name, node2.attrs, node2.text, node2.children)
      expect(node1).to be == fake_node
    end

    it "returns false when the attributes are different" do
      node1 = build(:xml_node, attrs: {attr1: "abc"} )
      node2 = build(:xml_node, attrs: {attr1: "xyz"} )
      expect(node1).not_to be == node2
    end

    it "returns false when the text is different" do
      node1 = build(:xml_node, text: "abc")
      node2 = build(:xml_node, text: "xyz")
      expect(node1).not_to be == node2
    end

    it "returns false when the children are different" do
      node1 = build(:xml_node, children: [build(:xml_node, name: "a", text: "123"), build(:xml_node, name: "b", text: "xyz")] )
      node2 = build(:xml_node, children: [build(:xml_node, name: "a", text: "456"), build(:xml_node, name: "b", text: "abc")] )
      expect(node1).not_to be == node2
    end

    it "returns false when the name is different" do
      node1 = build(:xml_node, name: "foo")
      node2 = build(:xml_node, name: "bar")
      expect(node1).not_to be == node2
    end
  end

  describe "#eql?" do
    it "returns true when compared to itself" do
      node = build(:xml_node)
      expect(node).to be_eql(node)
    end

    it "returns true when compared an identically configured node" do
      node1 = build(:xml_node)
      node2 = build(:xml_node)
      expect(node1).to be_eql(node2)
    end

    it "returns false when compared to an object that looks like the node" do
      node1 = build(:xml_node)
      node2 = build(:xml_node)
      fake_node_class = Struct.new(:name, :attrs, :text, :children)
      fake_node = fake_node_class.new(node2.name, node2.attrs, node2.text, node2.children)
      expect(node1).not_to be_eql(fake_node)
    end

    it "returns false when the attributes are different" do
      node1 = build(:xml_node, attrs: {attr1: "abc"} )
      node2 = build(:xml_node, attrs: {attr1: "xyz"} )
      expect(node1).not_to be_eql(node2)
    end

    it "returns false when the text is different" do
      node1 = build(:xml_node, text: "abc")
      node2 = build(:xml_node, text: "xyz")
      expect(node1).not_to be_eql(node2)
    end

    it "returns false when the children are different" do
      node1 = build(:xml_node, children: [build(:xml_node, name: "a", text: "123"), build(:xml_node, name: "b", text: "xyz")] )
      node2 = build(:xml_node, children: [build(:xml_node, name: "a", text: "456"), build(:xml_node, name: "b", text: "abc")] )
      expect(node1).not_to be_eql(node2)
    end

    it "returns false when the name is different" do
      node1 = build(:xml_node, name: "foo")
      node2 = build(:xml_node, name: "bar")
      expect(node1).not_to be_eql(node2)
    end
  end

  describe "#equal?" do
    it "returns true tested against itself" do
      node = build(:xml_node)
      expect(node).to be_equal(node)
    end
    it "returns true when compared an identically configured node" do
      node = build(:xml_node)
      node2 = build(:xml_node)
      expect(node).not_to be_equal(node2)
    end
  end

  describe "#children" do
    let(:children) { [] }
    let(:node) { build(:xml_node, children: children) }

    it "returns a Hash" do
      expect(node.children).to be_a(Hash)
    end

    it "is empty when there are no children" do
      expect(node.children).to be_empty
    end

    context "with children" do
      let(:children) {
        [
          build(:xml_node, name: "a", text: "1"),
          build(:xml_node, name: "a", text: "2"),
          build(:xml_node, name: "b", text: "3"),
          build(:xml_node, name: "c", text: "4")
        ]
      }

      specify "the keys are all symbols" do
        expect(node.children.keys).to contain_exactly(kind_of(Symbol), kind_of(Symbol), kind_of(Symbol))
      end
      specify "the keys are names of the children" do
        expect(node.children.keys).to contain_exactly(:a, :b, :c)
      end

      specify "the corresponding values are collections of the child nodes" do
        expect(node.children[:a]).to contain_exactly(
          build(:xml_node, name: "a", text: "1"), 
          build(:xml_node, name: "a", text: "2"))
        expect(node.children[:b]).to contain_exactly(
          build(:xml_node, name: "b", text: "3"))
        expect(node.children[:c]).to contain_exactly(
          build(:xml_node, name: "c", text: "4"))
      end
    end
  end

  describe "#[]" do
    it "returns an empty array if there are no child elements for the given name" do
      node = build(:xml_node)
      expect(node[:foo]).to eq([])
    end

    it "returns an array the matching child nodes in the order in which they were added" do
      child1 = build(:xml_node, name: :woof)
      child2 = build(:xml_node, name: :woof)
      child3 = build(:xml_node, name: :woof)
      child4 = build(:xml_node, name: :bark)
      child5 = build(:xml_node, name: :bark)
      child6 = build(:xml_node, name: :bark)
      node = build(:xml_node, children: [child1, child4, child2, child5, child3, child6])
      children = node[:woof]
      expect(children[0]).to be(child1)
      expect(children[1]).to be(child2)
      expect(children[2]).to be(child3)
    end

    it "accepts either a String or a Symbol, treating them equally" do
      child = build(:xml_node, name: :moo)
      node = build(:xml_node, children: [ child ])
      expect(node[:moo]).to eq([child])
      expect(node["moo"]).to eq([child])
    end
  end

  describe "#child_names" do
    context "with no children" do
      it "returns an empty array" do
        node = build(:xml_node)
        expect(node.child_names).to eq([])
      end
    end
    context "with children" do
      it "returns an array of symbols for all the names of the child elements" do
        children = [
          build(:xml_node, name: :a),
          build(:xml_node, name: :a),
          build(:xml_node, name: :b),
          build(:xml_node, name: :b),
          build(:xml_node, name: :c),
          build(:xml_node, name: :c)
        ]
        node = build(:xml_node, children: children)
        expect(node.child_names).to contain_exactly(:a, :b, :c)
      end
    end
  end

  describe "#num_children" do
    context "with no children" do
      let(:node) { build(:xml_node) }
      it "returns 0" do
        expect(node.num_children).to eq(0)
      end
    end

    context "with a bunch of children added" do
      let(:node) { build(:xml_node, children: children) }
      let(:children) { build_list(:xml_node, 50) }
      it "returns the total number of children" do
        expect(node.num_children).to eq(50)
      end
    end
  end

  describe "#text" do
    it "returns an empty string when the node has no text" do
      node = build(:xml_node)
      expect(node.text).to eq("")
    end

    it "returns the string of text assigned to the node" do
      node = build(:xml_node, text: "hey there big boy")
      expect(node.text).to eq("hey there big boy")
    end
  end
  describe "#name" do
    it "it returns the name of the node as a symbol" do
      node = build(:xml_node, name: :foobar)
      expect(node.name).to be(:foobar)
    end
  end
end
