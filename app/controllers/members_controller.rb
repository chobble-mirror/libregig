class MembersController < ApplicationController
  include AccessPermissions
  include EventsHelper

  before_action :set_member_events, only: :show
  before_action :set_view, only: :show

  def index
    # Get skills for the current set of members
    @skills =
      Skill.joins(:members)
        .where(members: {id: @members.pluck(:id)})
        .distinct
        .order(:name)

    # Filter members by skill if skill_id parameter is present
    if params[:skill_id].present?
      @skill = Skill.find(params[:skill_id])
      @members =
        @members
          .joins(:skills)
          .where(skills: {id: params[:skill_id]})
    end
  end

  def edit
  end

  def show
  end

  def new
    @member = Member.new
  end

  def create
    @member = Member.new(member_params)
    return render :new, status: :unprocessable_entity unless @member.save

    @permission = Permission.create(
      item_type: "Member",
      item_id: @member.id,
      user: Current.user,
      status: :owned,
      permission_type: "edit"
    )
    return render :new, status: :unprocessable_entity unless @permission.save

    redirect_to @member, notice: "Member was successfully created."
  end

  def update
    Member.transaction do
      @member.assign_attributes(member_params)
      if @member.save
        redirect_to @member, notice: "Member was successfully updated."
      else
        logger.warn "members/update error: #{@member.errors.full_messages}"
        render :edit, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    logger.warn "members/update transaction error: #{e.message}"
    render :edit, status: :unprocessable_entity
  end

  def destroy
    @member.destroy!
    redirect_to members_url, notice: "Member was successfully destroyed."
  end

  private

  def member_params
    params.require(:member).permit(
      :name, :description, :skills_list, band_ids: []
    )
  end

  def set_view
    @views = %w[overview events]
    @views_subtitles = [nil, "(#{@events.count})"]
    @view =
      @views.include?(params["view"]) ?
        params["view"] :
        "overview"
  end

  def set_member_events
    @events = @member.events
      .then { |rel| filter_by_period(rel, params[:period]) }
      .then { |rel| sort_results(rel, params[:sort]) }
  end
end
