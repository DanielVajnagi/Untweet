FactoryBot.define do
  factory :tweet do
    body { "This is a sample tweet." }
    association :user
  end
end
