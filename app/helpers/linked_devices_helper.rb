module LinkedDevicesHelper
  def device_type_badge(device_type)
    case device_type
    when "api"
      content_tag(:span, "API", class: "bg-purple-600 text-white px-2 py-1 rounded-full text-xs")
    when "web"
      content_tag(:span, "Web", class: "bg-blue-600 text-white px-2 py-1 rounded-full text-xs")
    else
      badge_class = "bg-gray-600 text-white px-2 py-1 rounded-full text-xs"
      content_tag(:span, device_type.to_s.upcase, class: badge_class)
    end
  end

  def resource_link(type, id)
    obj = type.constantize.find_by(id: id)
    return "Unknown #{type}" unless obj

    name = obj.name.presence || "NOT SET"

    case type
    when "Event"
      link_to(name, event_path(obj), class: "text-purple-600")
    when "Band"
      link_to(name, band_path(obj), class: "text-blue-600")
    when "Member"
      link_to(name, member_path(obj), class: "text-green-600")
    else
      "#{type}: #{name}"
    end
  end

  def status_badge(device)
    if device.revoked?
      content_tag(:span, "Revoked", class: "bg-red-600 text-white px-2 py-1 rounded-full text-xs")
    else
      content_tag(:span, "Active", class: "bg-green-600 text-white px-2 py-1 rounded-full text-xs")
    end
  end

  def last_accessed_display(device)
    return "Never" unless device.last_accessed_at

    time_ago_in_words(device.last_accessed_at) + " ago"
  end
end
