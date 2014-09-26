require 'threatinator/feed'
require 'threatinator/parser'
require 'threatinator/fetcher'
require 'threatinator/fetchers/http'

FactoryGirl.define do
  factory :feed, class: Threatinator::Feed do
    sequence(:provider) { |n| "provider_#{n}" }
    sequence(:name) { |n| "name_#{n}" }
    fetcher_builder { lambda { Threatinator::Fetcher.new({}) } } 
    fetcher { nil }
    parser_builder { lambda { Threatinator::Parser.new({}) } } 
    parser { nil }
    filter_builders { [] }
    filters { [] }
    decoder_builders { [] }
    decoders { [] }
    parser_block { lambda { |*args| } }

    initialize_with { 
      opts = attributes.to_hash
      if fetcher = opts.delete(:fetcher)
        opts[:fetcher_builder] = Proc.new { fetcher }
      end
      if decoders = opts.delete(:decoders)
        decoders.each do |decoder|
          opts[:decoder_builders] << Proc.new { decoder }
        end
      end
      if filters = opts.delete(:filters)
        filters.each do |filter|
          if filter.kind_of?(::Proc)
            filter = Threatinator::Filters::Block.new(filter)
          end
          fb = Proc.new { filter }
          opts[:filter_builders] << fb
        end
      end
      if parser = opts.delete(:parser)
        opts[:parser_builder] = Proc.new { parser }
      end
      new(opts) 
    }

    trait :http do
      url { "https://foobar/#{provider}/#{name}.data" }
      fetcher_builder { lambda { Threatinator::Fetchers::Http.new({url: url}) } } 
    end

    trait :mini do
      http
      sequence(:url) { |n| "http://x#{n}" }
      sequence(:provider) { |n| "x#{n}" }
      sequence(:name) { |n| "x#{n}" }
    end
  end

end

