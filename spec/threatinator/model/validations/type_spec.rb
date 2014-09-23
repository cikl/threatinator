require 'spec_helper'
require 'threatinator/model/validations/type'

describe Threatinator::Model::Validations::TypeValidator do
  before :each do
    module Examples
      class Person 
        include ActiveModel::Validations
        include Threatinator::Model::Validations
        attr_accessor :name, :age
      end
    end
  end

  after :each do
    Examples::Person.clear_validators!
  end

  it "validates that the value is an instance of the class specified by :type" do
    Examples::Person.validates :name, type: String
    person = Examples::Person.new
    expect(person).not_to be_valid

    person.name = :asdf
    expect(person).not_to be_valid

    person.name = "Mike"
    expect(person).to be_valid

    Examples::Person.validates :age, type: Integer
    expect(person).not_to be_valid
    person.age = :eight
    expect(person).not_to be_valid
    person.age = 8
    expect(person).to be_valid
  end
end
