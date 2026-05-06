require 'securerandom'

FactoryBot.define do
  factory :event do
    title { Faker::Lorem.sentence(word_count: 3) }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    start_date { Faker::Time.forward(days: 30, period: :evening) }
    end_date { start_date + 2.hours }
    image_url { Faker::Internet.url }
    external_id { SecureRandom.uuid }
    location { "#{Faker::Address.city}, #{Faker::Address.state}" }
    price { rand(0.0..100.0).round(2) }
    upvotes_count { rand(0..50) }
    downvotes_count { rand(0..20) }
  end
end
