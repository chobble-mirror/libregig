require "test_helper"

class BandsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organiser_user = create(:user_organiser)
    @member_user = create(:user_member)

    @band_with_members = create(
      :band,
      owner: @organiser_user,
      view_member: @member_user
    )
    @band_with_members.members << create(:member)

    @band_without_members = create(:band, owner: @organiser_user)
    @event_past = create(
      :event_past,
      bands: [@band_with_members, @band_without_members]
    )

    @solo_member_user = create(:user_member)
    @solo_member = create(:member, owner: @solo_member_user)
    @solo_band = create(
      :band,
      owner: @solo_member_user,
      band_member: @solo_member
    )
  end

  context "#index" do
    context "when the user has multiple bands" do
      should "get index" do
        log_in_as @organiser_user
        get bands_url
        assert_response :success
        assert assigns(:bands)
      end
    end

    context "when the user has no bands" do
      should "show new band template" do
        log_in_as create(:user)
        get bands_url
        assert_redirected_to new_band_url
      end
    end

    context "when a member has one band" do
      should "show band" do
        log_in_as @solo_member_user
        get bands_url
        assert_redirected_to band_url(@solo_band)
      end
    end
  end

  context "#index sorting" do
    setup do
      @user = create(:user_organiser)
      @bands = ["ZZZ", "AAA", "MMM"].map.with_index do |name, index|
        create(
          :band,
          name: "#{name} Band",
          created_at: (index + 1).days.ago,
          owner: @user
        )
      end
      log_in_as @user
    end

    {
      nil => :name_asc,
      "name DESC" => :name_desc,
      "created_at ASC" => :created_asc,
      "created_at DESC" => :created_desc,
      "invalid_column ASC" => :name_asc
    }.each do |sort_param, expected_order|
      should "sort bands correctly with sort param '#{sort_param}'" do
        get bands_url, params: {sort: sort_param}

        expected_bands =
          case expected_order
          when :name_asc
            [@bands[1], @bands[2], @bands[0]]
          when :name_desc
            [@bands[0], @bands[2], @bands[1]]
          when :created_asc
            [@bands[2], @bands[1], @bands[0]]
          when :created_desc
            [@bands[0], @bands[1], @bands[2]]
          else
            raise "No expected order?"
          end

        assert_equal expected_bands, assigns(:bands)
      end
    end
  end

  context "#new" do
    setup do
      log_in_as @organiser_user
    end

    should "get new band form" do
      get new_band_url

      assert_response :success
      assert assigns(:band)
    end

    should "redirect new band form unless organiser" do
      log_in_as @member_user
      get new_band_url

      assert_response :redirect
      assert_redirected_to bands_url
    end
  end

  context "#show" do
    should "show band" do
      log_in_as @organiser_user
      get band_url(@band_with_members)

      assert_response :success
      assert assigns(:band)
    end

    should "show read-only band" do
      log_in_as @member_user
      get band_url @band_without_members

      assert_response :success

      assert_equal @band_without_members, assigns(:band)
      assert_equal true, assigns(:read_only)
    end
  end

  context "#edit" do
    should "get edit band form" do
      log_in_as @organiser_user
      get edit_band_url(@band_with_members)

      assert_response :success
      assert assigns(:band)
    end

    should "deny for read-only band" do
      log_in_as @member_user
      get edit_band_url(@band_with_members)

      assert_response :not_found
    end
  end

  context "#create" do
    setup do
      log_in_as @organiser_user
    end

    should "create new band" do
      name = SecureRandom.random_number(4294967295).to_s
      description = SecureRandom.random_number(4294967295).to_s

      assert_difference("Band.count") do
        post bands_url, params: band_params(name:, description:)
      end
      assert_response :redirect
      band = assigns(:band)
      assert_equal name, band.name
      assert_equal description, band.description
      assert_equal "Band was successfully created", flash[:notice]
    end

    should "render new band form if band save fails" do
      Band.any_instance.expects(:save!).returns(false)

      assert_no_difference("Band.count") do
        post bands_url, params: band_params(
          name: "New Band", description: "New description"
        )
      end

      assert_response :unprocessable_entity
      assert_template :new
    end
  end

  context "#update" do
    should "update band" do
      log_in_as @organiser_user
      patch band_url(@band_with_members), params: band_params(
        name: "Updated Name", description: "Updated Description"
      )

      assert_redirected_to band_url(@band_with_members)
      assert_equal "Band was successfully updated.", flash[:notice]

      @band_with_members.reload
      assert_equal "Updated Name", @band_with_members.name
      assert_equal "Updated Description", @band_with_members.description
    end

    should "render edit band form if update fails" do
      log_in_as @organiser_user
      Band.any_instance.expects(:update).returns(false)

      patch band_url(@band_with_members), params: band_params(
        name: "Updated Name", description: "Updated Description"
      )

      assert_response :success
      assert_template :edit
    end

    should "deny access to read-only bands" do
      log_in_as @member_user
      patch band_url(@band_with_members), params: band_params(
        name: "Updated Name", description: "Updated Description"
      )
      assert_response :not_found
    end
  end

  context "#destroy" do
    should "destroy band" do
      log_in_as @organiser_user
      assert_difference("Band.count", -1) do
        delete band_url(@band_without_members)
      end

      assert_redirected_to bands_url
      assert_equal "Band deleted!", flash[:notice]
    end

    should "not destroy band if user is member" do
      log_in_as @member_user
      assert_no_difference("Band.count") do
        delete band_url(@band_without_members)
      end
      assert_response :not_found
    end

    should "not destroy band if user is not owner" do
      other_organiser_user = create(:user_organiser)
      log_in_as other_organiser_user
      assert_no_difference("Band.count") do
        delete band_url(@band_without_members)
      end
      assert_response :not_found
    end

    should "not destroy an undeletable band" do
      log_in_as @organiser_user
      band = create(:band, owner: @organiser_user)
      band.members << create(:member)

      assert_no_difference "Band.count" do
        delete band_url(band)
      end

      assert_redirected_to band
      assert_nil flash[:notice]

      alert = "Cannot delete record because dependent band members exist"
      assert_equal alert, flash[:alert]
    end
  end

  private

  def band_params(name:, description:)
    {
      band: {
        name: name,
        description: description
      }
    }
  end
end
