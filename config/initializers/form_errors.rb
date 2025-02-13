ActionView::Base.field_error_proc = proc do |html_tag, instance|
  if html_tag.start_with?("<label")
    # Wrap labels with field_with_errors div
    %(<div class="field_with_errors">#{html_tag}</div>).html_safe
  else
    # Return input fields as-is
    html_tag.html_safe
  end
end
