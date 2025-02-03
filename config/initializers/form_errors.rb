ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  if html_tag.match?(/\A<label/)
    # Wrap labels with field_with_errors div
    %Q(<div class="field_with_errors">#{html_tag}</div>).html_safe
  else
    # Return input fields as-is
    html_tag.html_safe
  end
end
