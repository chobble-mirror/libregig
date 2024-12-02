FactoryBot.define do
  factory :user_mail, class: UserMail do
    sequence(:subject) { |n| "user mail subject #{format("%05d", n)}" }
    sequence(:recipient) { |n| "user mail recipient #{format("%05d", n)}" }
    sequence(:template) { |n| "confirm_registration" }
    state { 0 }
    user { create(:user_organiser) }
    params { {name: "User"} }

    factory :user_mail_sending do
      state { 1 }
    end

    factory :user_mail_sent do
      state { 2 }
    end

    factory :user_mail_failed do
      state { 3 }
    end
  end
end
