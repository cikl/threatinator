require 'threatinator/record'

FactoryGirl.define do
  factory :record, class: Threatinator::Record do
    data { "some data" }
    opts { {} }
    initialize_with { new(attributes[:data], opts) }
  end
end


