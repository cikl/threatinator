require 'threatinator/record'

FactoryGirl.define do
  factory :record, class: Threatinator::Record do
    data { "some data" }

    line_number 1
    pos_start 0
    pos_end 9

    initialize_with { 
      new(attributes[:data], attributes) 
    }
  end
end


