module PermissionsHelper
  include ActionView::Helpers::UrlHelper
  
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
  
  def permission_status_color(status)
    case status.to_s
    when 'owned'
      'primary'
    when 'accepted'
      'success' 
    when 'pending'
      'warning'
    when 'rejected'
      'danger'
    else
      'secondary'
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
  
  def find_effective_permission_source(user, item)
    # Direct permission check
    direct_permission = Permission.where(
      user_id: user.id,
      item_type: item.class.to_s,
      item_id: item.id,
      status: ['owned', 'accepted']
    ).first
    
    return nil if direct_permission
    
    case item
    when Band
      find_band_permission_source(user, item)
    when Event
      find_event_permission_source(user, item)
    when Member
      find_member_permission_source(user, item)
    end
  end
  
  def find_band_permission_source(user, band)
    # Check permissions through members
    band.members.each do |member|
      permission = Permission.where(
        user_id: user.id,
        item_type: 'Member',
        item_id: member.id,
        status: ['owned', 'accepted']
      ).first
      
      return permission if permission
    end
    
    # Check permissions through events
    band.events.each do |event|
      permission = Permission.where(
        user_id: user.id,
        item_type: 'Event',
        item_id: event.id,
        status: ['owned', 'accepted']
      ).first
      
      return permission if permission
    end
    
    nil
  end
  
  def find_event_permission_source(user, event)
    # Check permissions through bands
    event.bands.each do |band|
      permission = Permission.where(
        user_id: user.id,
        item_type: 'Band',
        item_id: band.id,
        status: ['owned', 'accepted']
      ).first
      
      return permission if permission
    end
    
    # Check permissions through members in bands
    event.bands.each do |band|
      band.members.each do |member|
        permission = Permission.where(
          user_id: user.id,
          item_type: 'Member',
          item_id: member.id,
          status: ['owned', 'accepted']
        ).first
        
        return permission if permission
      end
    end
    
    nil
  end
  
  def find_member_permission_source(user, member)
    # Check permissions through bands
    member.bands.each do |band|
      permission = Permission.where(
        user_id: user.id,
        item_type: 'Band',
        item_id: band.id,
        status: ['owned', 'accepted']
      ).first
      
      return permission if permission
    end
    
    # Check permissions through events via bands
    member.bands.each do |band|
      band.events.each do |event|
        permission = Permission.where(
          user_id: user.id,
          item_type: 'Event',
          item_id: event.id,
          status: ['owned', 'accepted']
        ).first
        
        return permission if permission
      end
    end
    
    nil
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
