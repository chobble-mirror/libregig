require "test_helper"

class BandTest < ActiveSupport::TestCase
  should have_many :band_members
  should have_many :members
  should have_many :events
  should have_many :event_bands

  should validate_presence_of(:name)
  should validate_presence_of(:description)

  setup do
    @band = create(
      :band_with_members,
      name: "Awesome Band",
      description: "Rock Band"
    )
  end

  context "validations" do
    should "be valid with valid attributes" do
      assert @band.valid?
    end

    should "not be deletable if has members" do
      refute @band.destroy
      assert_equal "Cannot delete record because dependent band members exist", @band.errors.full_messages.to_sentence
    end

    should "deletable if has no members" do
      @band.members.destroy_all
      assert @band.destroy
    end
  end

  context "#url" do
    should "return correct url" do
      @band.save!
      assert_equal Rails.application.routes.url_helpers.edit_band_path(@band), @band.url
    end
  end

  context "Band audits" do
    setup do
      @user = create(:user)
      @band = create(:band, name: "Original Name")
      Current.user = @user
    end

    should "create audit log entry for changed columns" do
      assert_difference("BandsAudit.count") do
        @band.update!(name: "Updated Name")
      end

      audit = BandsAudit.last
      assert_equal @band.id, audit.band_id
      assert_equal "name", audit.column_changed
      assert_equal "Original Name", audit.old_value
      assert_equal "Updated Name", @band.name
      assert_equal @user.id, audit.user_id
    end

    should "not log unchanged columns" do
      assert_no_difference("BandsAudit.count") do
        @band.update!(name: "Original Name")
      end
    end
  end
end
