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
    return events unless Event.attribute_names.include?(column.to_s)
    events.order(column => direction)
  end

  def extract_sort_params(sort_param)
    col, dir = sort_param.to_s.split
    dir = %w[desc DESC].include?(dir) ? :desc : :asc
    [col.presence || :date, dir]
  end
end
