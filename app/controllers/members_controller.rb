class MembersController < ApplicationController
  before_action :set_member, except: %i[index new create]
  before_action :deny_read_only, only: %i[edit update destroy]

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
    Member.transaction do
      @member.assign_attributes(member_params)
      if @member.save
        redirect_to @member, notice: "Member was successfully updated." and return
      else
        logger.warn "members/update error: #{@member.errors.full_messages}"
        render :edit, status: :unprocessable_entity and return
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

  def set_member
    @band = Current.user.bands.find(params[:band_id]) if params[:band_id]
    @member = Current.user.members.find_by(id: params[:id])
    if @band && !@member
      @member = @band.members.find_by(id: params[:id])
      @read_only = true
    end
    redirect_to bands_url, alert: "Member not found" unless @member
  end

  def deny_read_only
    redirect_to @member if @read_only
  end

  def member_params
    params.require(:member).permit(
      :name, :description, :skills_list, band_ids: []
    )
  end
end
