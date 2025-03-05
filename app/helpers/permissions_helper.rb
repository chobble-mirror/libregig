module PermissionsHelper
  def potential_users
    # Get all non-admin users (both members and organisers) sorted by username,
    # excluding current user
    users =
      User
        .where
        .not(user_type: :admin)
        .where
        .not(id: Current.user.id)
        .order(:username)
        .pluck(:username, :id)

    if users.any?
      # Add a "Please select" option with empty value as the first option
      [["Please select", ""]] + users
    else
      []
    end
  end

  def potential_items(owner)
    invitable_klasses = [Event, Band, Member]
    invitable_klasses.flat_map do |klass|
      pluck_and_prefix(klass, owner)
    end
  end

  def get_access_level(user, item)
    case item
    when Member then get_ownership(user, item, :members, Member)
    when Band then get_ownership(user, item, :bands, Band)
    when Event then get_ownership(user, item, :events, Event)
    else raise "Invalid item type: #{item.class}"
    end
  end

  def get_ownership(user, item, method, klass)
    if (direct_permission = user.send(method).find_by(id: item.id))
      direct_permission[:permission_type]
    elsif klass.permitted_for(user.id).find_by(id: item.id)
      "view"
    end
  end

  private

  def pluck_and_prefix(klass, owner)
    owned_permissions = owner.send(:"#{klass.to_s.downcase.pluralize}")
    owned_item_ids = owned_permissions.pluck(:id)
    items = klass.where(id: owned_item_ids).pluck(:id, :name)
    items.map do |id, name|
      ["#{name} (#{klass})", "#{klass}_#{id}"]
    end
  end
end
