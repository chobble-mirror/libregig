# This file should ensure the existence of records required to run the application
# in every environment (production, development, test). The code here should be
# idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created
# alongside the database with db:setup).

module Seeds
  require "factory_bot_rails"
  include FactoryBot::Syntax::Methods

  admin_user = FactoryBot.build(
    :user_admin,
    username: "admin",
    name: "Admin User",
    email: "seed_admin@test.com"
  )
  admin_user.save if admin_user.valid?

  organiser_user = FactoryBot.build(
    :user_organiser,
    email: "seed_organiser@test.com",
    name: "Seed Organiser",
    username: "seed_organiser"
  )

  unless organiser_user.save
    organiser_user = User.find_by(username: "seed_organiser")
  end

  member_organiser = FactoryBot.build(:member_with_user_with_edit_permission)
  member_organiser.save

  FactoryBot.build(
    :user_member,
    email: "seed_member1@test.com",
    name: "Seed Member One",
    username: "seed_member1"
  )

  FactoryBot.build(
    :user_member,
    email: "seed_member2@test.com",
    name: "Seed Member Two",
    username: "seed_member2"
  )

  member_user3 = FactoryBot.build(
    :user_member,
    email: "seed_member3@test.com",
    name: "Seed Member Three",
    username: "seed_member3"
  )

  FactoryBot.build(
    :permission,
    :for_member,
    user: member_user3
  )

  band = FactoryBot.build(
    :permission,
    :for_band
  ).item
  band.members << FactoryBot.build(:member)
  band.members << FactoryBot.build(:member)
  band.members << FactoryBot.build(:member)

  FactoryBot.build(
    :permission,
    :for_event,
    user: organiser_user
  )
end
