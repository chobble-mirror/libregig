module PermissionsHelper
  def potential_users
    User.member.pluck(:username, :id)
  end

  def potential_items(owner)
    invitable_klasses = [Event, Band, Member]
    invitable_klasses.flat_map do |klass|
      pluck_and_prefix(klass, owner)
    end
  end

  def get_access_level(user, item)
    case item
    when Member then
      get_ownership_member(user, item)
    when Band then
      get_ownership_band(user, item)
    when Event then
      get_ownership_event(user, item)
    else raise "Invalid item type: #{item.class}"
    end
  end

  private

  def get_ownership_member(user, member)
    user_member = user.members.find_by(id: member.id)
    return user_member[:permission_type] if user_member

    band_ids = []
    event_ids = []
    member_ids = []

    user_member_ids = user.members&.pluck(:id)
    if user_member_ids.any?
      member_band_ids = BandMember.where(member_id: member_ids).pluck(:band_id)
      if member_band_ids.any?
        band_ids += member_band_ids
        event_ids +=
          EventBand.where(event_id: member_band_ids).pluck(:band_id)
      end
    end

    user_event_ids = user.events&.pluck(:id)
    if user_event_ids.any?
      event_band_ids = EventBand.where(event_id: user_event_ids).pluck(:band_id)
      if event_band_ids.any?
        band_ids += event_band_ids
        member_ids +=
          BandMember.where(band_id: event_band_ids).pluck(:member_id)
      end
    end

    user_band_ids = user.bands&.pluck(:id)
    if user_band_ids.any?
      band_member_ids = BandMember.where(band_id: band_ids).pluck(:member_id)
      member_ids += band_member_ids
    end

    return "view" if member_ids.any? {|id| id == member.id}

    return nil
  end

  def pluck_and_prefix(klass, owner)
    owned_permissions = owner.send(:"#{klass.to_s.downcase.pluralize}")
    owned_item_ids = owned_permissions.pluck(:item_id)
    items = klass.where(id: owned_item_ids).pluck(:id, :name)
    items.map do |id, name|
      ["#{name} (#{klass})", "#{klass}_#{id}"]
    end
  end
end
