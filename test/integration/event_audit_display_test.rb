require "test_helper"

class EventAuditDisplayTest < ActionDispatch::IntegrationTest
  setup do
    @user_organiser = create(:user_organiser)
    @event_one = create(:event, owner: @user_organiser)
    
    assert_equal @user_organiser, @event_one.owner
    
    # Create audit records
    Current.user = @user_organiser
    @event_one.update!(name: "Updated Event Name")
    @event_one.update!(description: "New description")
  end

  context "#show" do
    context "with audit history" do
      should "get show" do
        log_in_as @user_organiser
        get event_path(@event_one)
        
        assert_response :success
        assert_equal @event_one, assigns(:event)
      end
    end
    
    context "without audit history" do
      setup do
        @event_two = create(:event, owner: @user_organiser)
        assert_equal @user_organiser, @event_two.owner
      end
      
      should "get show" do
        log_in_as @user_organiser
        get event_path(@event_two)
        
        assert_response :success
        assert_equal @event_two, assigns(:event)
      end
    end
  end
end