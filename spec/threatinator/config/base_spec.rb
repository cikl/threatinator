require 'spec_helper'
require 'threatinator/config/base'

describe Threatinator::Config::Base do
  describe '.properties' do
    class Foobar3 < Threatinator::Config::Base
      attribute :deep1, String, description: "deep prop1"
      attribute :deep2, String, description: "deep prop2"
    end

    class Foobar2 < Threatinator::Config::Base
      attribute :nested_prop1, String, description: "Nested prop1"
      attribute :nested_prop2, String, description: "Nested prop2"
      attribute :deep, Foobar3
    end

    class Foobar1 < Threatinator::Config::Base
      attribute :prop1, String, description: "This is prop1"
      attribute :prop2, Boolean, description: "This is prop2"
      attribute :nested1, Foobar2
      attribute :nested2, Foobar2
    end

    it "should return a hash of all properties and nested properties" do
      expect(Foobar1.properties).to match({
        "prop1" => ["This is prop1", Axiom::Types::String],
        "prop2" => ["This is prop2", Axiom::Types::Boolean],
        "nested1.nested_prop1" => ["Nested prop1", Axiom::Types::String],
        "nested1.nested_prop2" => ["Nested prop2", Axiom::Types::String],
        "nested1.deep.deep1" => ["deep prop1", Axiom::Types::String],
        "nested1.deep.deep2" => ["deep prop2", Axiom::Types::String],
        "nested2.nested_prop1" => ["Nested prop1", Axiom::Types::String],
        "nested2.nested_prop2" => ["Nested prop2", Axiom::Types::String],
        "nested2.deep.deep1" => ["deep prop1", Axiom::Types::String],
        "nested2.deep.deep2" => ["deep prop2", Axiom::Types::String]
      })
    end
  end
end
