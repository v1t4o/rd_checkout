FactoryBot.define do
  factory :cart_item do
    association :cart
    association :product
    quantity { 2 }
  end
end