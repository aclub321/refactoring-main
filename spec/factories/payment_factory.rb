FactoryBot.define do
  factory :payment do
    amount_cents { 2048 }
    new { true }
    verified { true }
    cancelled { false }
    processed { false }

    agent
    contract

    trait :not_ready_for_export do
      cancelled { true }
    end
  end
end
