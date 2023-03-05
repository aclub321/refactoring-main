FactoryBot.define do
  factory :agent do
    sequence(:name) { |n| "agent_#{n}" }
    sequence(:email) { |n| "agent_#{n}@example.com" }
  end
end
