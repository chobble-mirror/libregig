class MembersController < ApplicationController
  before_action :set_member, only: [:show, :edit, :update, :destroy]

  def edit
  end

  def show
  end

  def index
    @members = Member.all
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
    if @member.update(member_params)
      redirect_to @member, notice: "Member was successfully updated."
    else
      logger.warn "members/update error: #{@member.errors.full_messages}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @member.destroy!
    redirect_to members_url, notice: "Member was successfully destroyed."
  end

  private

  def set_member
    @member = Current.user.members.find(params[:id])
  end

  def member_params
    params.require(:member).permit(:name, :description, skill_ids: [], band_ids: [])
  end
end
