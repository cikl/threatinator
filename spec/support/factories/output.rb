require 'threatinator/output'

FactoryGirl.define do
  sequence :output_name do |n|
    name = "output_test#{n}"
    name.to_sym
  end
end



