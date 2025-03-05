module ApplicationHelper
  def page_heading(str)
    content_tag(:h1, str, class: "text-gray-900 text-xl")
  end

  def filter_link(name, path, css_class, active)
    link_to_if(!active, name, path, class: "#{css_class} hover:underline") do
      content_tag(:span, name, class: "#{css_class} font-bold")
    end
  end

  def table_headers(sort_param_name, columns, resource = nil)
    query_params = request.query_parameters.merge({}).except(sort_param_name)

    capture do
      columns.each do |column|
        concat(
          content_tag(:th,
            table_header_sort(
              resource || controller_name,
              column[:name],
              column[:display],
              column[:default],
              query_params,
              sort_param_name
            ),
            class: column[:class],
            style: column[:wide] ? nil : "width: 1%")
        )
      end
    end
  end

  def table_header_sort(
    resource,
    column,
    display_text,
    default_sort_column = nil,
    request_params = nil,
    sort_param_name = :sort,
    default_sort_direction = "asc"
  )
    sort_param = sort_param_name.to_sym
    current_sort_column, current_sort_direction = params[sort_param]&.split
    current_sort_column ||= default_sort_column
    current_sort_direction ||= default_sort_direction

    if current_sort_column == column
      new_sort_direction = (current_sort_direction == "asc") ? "desc" : "asc"
      sort_icon = sort_direction_icon(current_sort_direction)
    else
      new_sort_direction = default_sort_direction
      sort_icon = ""
    end

    query_params = request_params || request.query_parameters

    new_params = query_params
      .except(:page, sort_param)
      .merge(sort_param => "#{column} #{new_sort_direction}")

    # Preserve period parameter if it exists
    new_params[:period] = request.params[:period] if request.params[:period]

    sort_url = url_for(new_params)

    link_to "#{display_text}#{sort_icon}".html_safe, sort_url
  end

  def flash_banner(key, msg = nil, &block)
    content_tag :div, class: "#{key} banner" do
      if block && msg.blank?
        msg = capture(&block)
      end

      concat(content_tag(:div, msg))
      concat(hidden_checkbox_tag(key))
      concat(close_button(key))
    end
  end

  private

  def sort_direction_icon(direction)
    case direction
    when "asc" then " <span>▼</span>"
    when "desc" then " <span>▲</span>"
    else ""
    end
  end

  def hidden_checkbox_tag(key)
    tag.input type: "checkbox", class: "hidden", id: "banneralert-#{key}"
  end

  def close_button(key)
    tag.label class: "close", style: "width:30px", for: "banneralert-#{key}" do
      tag.svg class: "fill-current h-6 w-6", role: "button", xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 20 20" do
        concat(tag.title("Close"))
        concat(tag.path(d: "M14.348 14.849a1.2 1.2 0 0 1-1.697 0L10 11.819l-2.651 3.029a1.2 1.2 0 1 1-1.697-1.697l2.758-3.15-2.759-3.152a1.2 1.2 0 1 1 1.697-1.697L10 8.183l2.651-3.031a1.2 1.2 0 1 1 1.697 1.697l-2.758 3.152 2.758 3.15a1.2 1.2 0 0 1 0 1.698z"))
      end
    end
  end
end
