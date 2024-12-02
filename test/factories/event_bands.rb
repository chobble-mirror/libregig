FactoryBot.define do
  factory :event_band, class: EventBand do
    band { create(:band_with_members) }
    event { create(:event) }
  end
end
