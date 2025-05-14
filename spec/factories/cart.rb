FactoryBot.define do
  factory :cart do
    status { :active }
    last_interaction_at { Time.current }
  end
end