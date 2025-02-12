require "test_helper"

class PermissionsControllerTest < ActionDispatch::IntegrationTest
  include FactoryBot::Syntax::Methods

  context "PermissionsController" do
    setup do
      @admin = create(:user, user_type: :admin)
      @member = create(:user_member)
      @member_two = create(:user_member)
      @organiser = create(:user_organiser)

      @my_event = create(:event, owner: @organiser)

      assert_equal @organiser.events.to_a, [@my_event]

      @permission = create(
        :permission,
        bestowing_user: @organiser,
        user: @member,
        item: @my_event
      )

      @valid_permission_params = {
        permission: {
          user_id: @member.id,
          item: "Event_#{@my_event.id}",
          permission_type: "edit"
        }
      }

      assert_not_nil @permission, "Invitation should not be nil in setup"
      assert_not_nil @permission.item, "Item should not be nil in setup"
    end

    context "#index" do
      should "allow admin to view all permissions" do
        log_in_as @admin

        get permissions_path

        assert_response :success
        assert_equal Permission.count, assigns(:permissions).size
      end

      should "allow organiser to view their sent permissions" do
        log_in_as @organiser

        get permissions_path

        assert_response :success

        assert assigns(:permissions).all? do |permission|
          permission.bestowing_user_id == @organiser.id ||
            (permission.bestowing_user_id.nil? && permission.user_id == @organiser.id)
        end
      end

      should "allow user to view their received permissions" do
        log_in_as @member

        get permissions_path

        assert_response :success
        assert assigns(:permissions).all? { |i| i.user_id == @member.id }
      end

      should "not allow member to view other users' permissions" do
        log_in_as @member_two

        other_organiser = create(:user_organiser)
        other_owned_event = create(:event, owner: other_organiser)

        get permissions_path

        assert_response :success
        assert assigns(:permissions).none? { |i| i == other_permission }
      end
    end

    context "#new" do
      context "as organizer" do
        should "display new permission form with required options" do
          log_in_as @organiser

          get new_permission_url

          assert_response :success
          assert assigns(:permission).new_record?
          assert assigns(:users).present?
          assert assigns(:items).present?
          assert_equal %w[view edit], assigns(:permission_types)
        end
      end

      context "as non-organizer" do
        should "forbid access" do
          member_user = create(:user_member)
          log_in_as member_user

          get new_permission_url

          assert_response :forbidden
          assert_equal "Organisers only", response.body
        end
      end
    end

    context "#create" do
      should "not allow sending an permission without item" do
        log_in_as @organiser

        invalid_permission_params = {
          permission: {
            user_id: @member.id,
            item: "",
            permission_type: "edit"
          }
        }

        assert_no_difference("Permission.count") do
          post permissions_path, params: invalid_permission_params
        end

        assert_response :unprocessable_entity
      end

      should "not allow sending an permission for someone else's item" do
        log_in_as @organiser

        not_my_event = create(:event)
        invalid_permission_params = {
          permission: {
            user_id: @member.id,
            item: "Event_#{not_my_event.id}",
            permission_type: "edit"
          }
        }

        assert_no_difference("Permission.count") do
          post permissions_path, params: invalid_permission_params
        end

        assert_response :unprocessable_entity
      end

      should "allow organiser to create an permission for an event" do
        log_in_as @organiser

        assert_difference("Permission.count", 1) do
          post permissions_path, params: @valid_permission_params
        end

        assert_response :redirect
        follow_redirect!
        assert_equal "Invitation created", flash[:notice]
      end

      should "not allow member to create an permission" do
        log_in_as @member

        assert_no_difference("Permission.count") do
          post permissions_path, params: @valid_permission_params
        end

        assert_response :forbidden
      end
    end

    context "#update" do
      setup do
        @permission = create(:permission, :for_event,
          bestowing_user: @organiser,
          user: @member,
          item: @my_event,
          permission_type: "edit",
          status: "pending")

        @permission_params_accepted = {status: "accepted"}
        @permission_params_rejected = {status: "rejected"}
      end

      should "allow member to accept an permission" do
        log_in_as @member

        patch permission_path(@permission),
          params: {permission: @permission_params_accepted}

        assert_response :redirect
        follow_redirect!
        assert_equal "Invitation accepted", flash[:notice]

        @permission.reload
        assert_equal "accepted", @permission.status
      end

      should "allow member to reject an permission" do
        log_in_as @member

        patch permission_path(@permission),
          params: {permission: @permission_params_rejected}

        assert_response :redirect
        follow_redirect!
        assert_equal "Invitation rejected", flash[:alert]

        @permission.reload
        assert_equal "rejected", @permission.status
      end

      should "not allow organiser to accept or reject permission" do
        log_in_as @organiser

        patch permission_path(@permission),
          params: {permission: @permission_params_accepted}

        assert_response :forbidden
      end

      should "not allow non-recipient to accept an permission" do
        log_in_as @member_two

        patch permission_path(@permission),
          params: {permission: @permission_params_accepted}

        assert_response :forbidden
        @permission.reload
        assert_equal "pending", @permission.status
      end

      should "not allow non-recipient to reject an permission" do
        log_in_as @member_two

        patch permission_path(@permission),
          params: {permission: @permission_params_rejected}

        assert_response :forbidden
        @permission.reload
        assert_equal "pending", @permission.status
      end

      should "not allow updating non-pending permissions" do
        log_in_as @member
        @permission.update!(status: "accepted")

        patch permission_path(@permission),
          params: {permission: @permission_params_rejected}

        assert_response :bad_request
        assert_equal "Invite not pending", response.body
        @permission.reload
        assert_equal "accepted", @permission.status
      end

      should "handle failed updates appropriately" do
        log_in_as @member

        organiser = create(:user_organiser)
        my_event = create(:event, owner: organiser)

        permission = create(
          :permission,
          status: "pending",
          bestowing_user: organiser,
          user: @member,
          item: my_event
        )

        invalid_params = {
          permission: {
            status: "invalid_status"
          }
        }
        patch permission_path(permission), params: invalid_params

        assert_nil flash[:notice]
        assert_nil flash[:alert]
        assert_response :bad_request
        assert_equal "Not updated", response.body

        @permission.reload

        assert_equal "pending", @permission.status
      end
    end

    context "#destroy" do
      should "allow admin to destroy permission" do
        log_in_as @admin

        assert_difference("Permission.count", -1) do
          delete permission_path(@permission)
        end

        assert_response :redirect
        follow_redirect!
        assert_equal "Invitation deleted", flash[:notice]
      end

      should "not allow organiser to destroy permission" do
        log_in_as @organiser

        assert_no_difference("Permission.count") do
          delete permission_path(@permission)
        end

        assert_response :forbidden
        @permission.reload
      end

      should "not allow member to destroy permission" do
        log_in_as @member

        assert_no_difference("Permission.count") do
          delete permission_path(@permission)
        end

        assert_response :forbidden
        @permission.reload
      end
    end
  end
end
