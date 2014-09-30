require 'threatinator/model/observables/ipv4'
require 'ip'

FactoryGirl.define do
  factory :ipv4, class: Threatinator::Model::Observables::Ipv4 do
    sequence(:ipv4) { |n| IP::V4.new(0xa000000 + n) } # Starts at 10.0.0.0

    initialize_with do
      opts = attributes.dup
      if opts[:ipv4].is_a?(::String)
        opts[:ipv4] = IP::V4.parse(opts[:ipv4])
      end
      new(opts)
    end
  end

  factory :ipv4s, class: Threatinator::Model::Observables::Ipv4Collection do
    values { [ ] }

    initialize_with do
      values = attributes[:values]

      values.map! do |v|
        if v.kind_of?(::String)
          v = build(:ipv4, ipv4: v)
        end
        v
      end

      new(values)
    end
  end
end



