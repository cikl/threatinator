require 'threatinator/model/observables/url_collection'
require 'addressable/uri'
require 'ip'

FactoryGirl.define do
  factory :url, class: ::Addressable::URI do
    url nil

    initialize_with do
      ::Addressable::URI.parse(attributes[:url])
    end
  end

  factory :urls, class: Threatinator::Model::Observables::UrlCollection do
    values { [ ] }

    initialize_with do
      values = attributes[:values]

      values.map! do |v|
        if v.kind_of?(::String)
          v = build(:url, url: v)
        end
        v
      end

      new(values)
    end
  end
end




