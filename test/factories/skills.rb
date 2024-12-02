FactoryBot.define do
  factory :skill, class: Skill do
    sequence(:name) { |n| "skill#{format("%05d", n)}" }
  end
end
