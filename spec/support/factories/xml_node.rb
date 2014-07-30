require 'threatinator/parsers/xml/node'

FactoryGirl.define do
  factory :xml_node, class: Threatinator::Parsers::XML::Node do
    name { "foo" }
    attrs { { } }
    text { "" }
    children { [] }

    initialize_with { 
      new(name, attrs: attrs, text: text, children: children) 
    }

    trait(:with_attrs) do
      attrs { {
        attr1: "val1",
        attr2: "val2"
      } }
    end

    trait(:with_children) do
      children { [
        build(:xml_node, name: "child1"),
        build(:xml_node, name: "child2"),
        build(:xml_node, name: "child3"),
      ] }
    end
  end

end



