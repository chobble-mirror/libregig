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

  private

  def pluck_and_prefix(klass, owner)
    owned_permissions = owner.send(:"owned_#{klass.to_s.downcase.pluralize}")
    owned_item_ids = owned_permissions.pluck(:item_id)
    items = klass.where(id: owned_item_ids).pluck(:id, :name)
    items.map do |id, name|
      ["#{name} (#{klass})", "#{klass}_#{id}"]
    end
  end
end
