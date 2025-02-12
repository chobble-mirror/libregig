require "test_helper"

class UserTest < ActiveSupport::TestCase
  context "validations" do
    should validate_presence_of(:username)
    should validate_uniqueness_of(:username)
    should validate_presence_of(:email)
    should validate_uniqueness_of(:email)
    should allow_value("test@example.com").for(:email)
    should_not allow_values("testytest", "test@", "bandapp.com", "@.com").for(:email)
    should_not allow_values("1234", "test@").for(:password)

    context "time zone" do
      setup { @user = build(:user) }

      should "accept valid time zones" do
        %w[Etc/UTC America/New_York Europe/London].each do |zone|
          @user.time_zone = zone
          assert @user.valid?, "#{zone} should be a valid time zone"
        end
      end

      should "reject invalid time zone" do
        @user.time_zone = "The Moon"
        refute @user.save
        assert_includes @user.errors[:time_zone], "The Moon is not a valid time zone"
      end

      should "allow blank time zone" do
        @user.time_zone = ""
        assert @user.valid?
        assert_equal "Etc/UTC", @user.time_zone
      end
    end

    context "password" do
      setup { @user = build(:user, password: nil) }

      should "enforce presence for new records" do
        refute @user.save
        assert_includes @user.errors[:password], "can't be blank"
      end

      should "enforce presence when password is set" do
        @user.password = "password"
        @user.save!
        @user.password = nil
        refute @user.save
        assert_includes @user.errors[:password], "can't be blank"
      end

      should "validate confirmation" do
        @user.password = "password123"
        @user.password_confirmation = "password123"
        assert @user.valid?

        @user.password_confirmation = "different_password"
        refute @user.valid?
        assert_includes @user.errors[:password_confirmation], "doesn't match Password"
      end
    end
  end

  context "associations" do
    should have_many(:permissions).dependent(:destroy)
    should have_many(:bands).through(:permissions)
    should have_many(:events).through(:permissions)
    should have_many(:members).through(:permissions)
  end

  context "enums" do
    should define_enum_for(:user_type).with_values(admin: 0, member: 1, organiser: 2)
  end

  should have_secure_password

  context "instance methods" do
    context "#owned_links" do
      setup do
        @user = create(:user)
        @items = %i[band event member].map do |item_type|
          create(item_type).tap do |item|
            create(:owned_permission, user: @user, item: item)
          end
        end
      end

      should "return all owned links" do
        owned_links = @user.owned_links
        @items.each { |item| assert_includes owned_links, item }
      end
    end

    %i[bands events members].each do |method|
      context "##{method}" do
        setup do
          @item_type = method.to_s.singularize.to_sym
          @other_item = create(@item_type)
          @owned_permission = create(:owned_permission, :"for_#{@item_type}")
          @target_item = @owned_permission.item
          @owner = @owned_permission.user
          @accepted_permission = create(:permission, item: @target_item, bestowing_user: @owned_permission.bestowing_user)
          @user = @accepted_permission.user
          @admin_user = create(:user_admin)
        end

        should "include accepted items for regular users" do
          assert_includes @user.send(method), @target_item
          refute_includes @user.send(method), @other_item
        end

        should "include owned items for owners" do
          assert_includes @owner.send(method), @target_item
          refute_includes @owner.send(method), @other_item
        end
      end
    end

    context "#confirmed?" do
      should "return true for admin users regardless of confirmation status" do
        assert create(:user_admin, confirmed: false).confirmed?
      end

      should "return true for confirmed non-admin users" do
        assert create(:user).confirmed?
      end

      should "return false for unconfirmed non-admin users" do
        refute create(:user_unconfirmed).confirmed?
      end
    end

    context "#to_param" do
      should "return username" do
        user = create(:user)
        assert_equal user.username, user.to_param
      end
    end

    context "#password_required?" do
      should "return true for new records" do
        assert User.new.send(:password_required?)
      end

      should "return true if password is present" do
        user = create(:user)
        user.password = "new_password"
        assert user.send(:password_required?)
      end

      should "return false for existing records with no password change" do
        refute create(:user).send(:password_required?)
      end
    end
  end

  context "callbacks" do
    should "downcase email before save" do
      user = create(:user, email: "INFO@TestEmail.Com")
      assert_equal "info@testemail.com", user.email
    end
  end
end
