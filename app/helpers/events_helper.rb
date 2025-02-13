module EventsHelper
  def filter_by_period(events, period)
    case period
    when "past" then events.past
    when "future", nil then events.future
    else events
    end
  end

  def filter_by_band(events, band_id)
    return events unless band_id.present? && band_id.to_i.positive?
    events.joins(:bands).where(bands: {id: band_id})
  end

  def sort_results(events, sort_param)
    column, direction = extract_sort_params(sort_param)
    unless Event.attribute_names.include?(column.to_s)
      return events.order(:start_date)
    end
    events.order(column => direction)
  end

  def extract_sort_params(sort_param)
    col, dir = sort_param.to_s.split
    dir = %w[desc DESC].include?(dir) ? :desc : :asc
    [col.presence || :start_date, dir]
  end

  def convert_seconds_to_duration(seconds)
    return nil if seconds < 60

    days = (seconds / 86400).floor
    remaining = seconds % 86400

    hours = (remaining / 3600).floor
    remaining %= 3600

    minutes = (remaining / 60).floor

    parts = []
    parts << "#{days} day#{"s" unless days == 1}" if days > 0
    parts << "#{hours} hour#{"s" unless hours == 1}" if hours > 0
    parts << "#{minutes} minute#{"s" unless minutes == 1}" if minutes > 0

    case parts.size
    when 1 then parts.first
    else
      parts[0...-1].join(", ") + " and #{parts.last}"
    end
  end
end
