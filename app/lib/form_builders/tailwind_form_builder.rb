module FormBuilders
  class TailwindFormBuilder < ActionView::Helpers::FormBuilder
    class_attribute :text_field_helpers, default: field_helpers - [:label, :check_box, :radio_button, :fields_for, :fields, :hidden_field, :file_field]
    #  leans on the FormBuilder class_attribute `field_helpers`
    #  you'll want to add a method for each of the specific helpers listed here if you want to style them

    TEXT_FIELD_STYLE = "text_field".freeze
    SELECT_FIELD_STYLE = "select_field".freeze
    SUBMIT_BUTTON_STYLE = "primary_button".freeze

    text_field_helpers.each do |field_method|
      define_method(field_method) do |method, options = {}|
        if options.delete(:tailwindified)
          super(method, options)
        else
          text_like_field(field_method, method, options)
        end
      end
    end

    def submit(value = nil, options = {})
      custom_opts, opts = partition_custom_opts(options)
      classes = apply_style_classes(SUBMIT_BUTTON_STYLE, custom_opts)

      super(value, {class: classes}.merge(opts))
    end

    def select(method, choices = nil, options = {}, html_options = {}, &)
      custom_opts, opts = partition_custom_opts(options)
      classes = apply_style_classes(SELECT_FIELD_STYLE, custom_opts, method)

      labels = labels(method, custom_opts[:label], options)
      field = super(method, choices, opts, html_options.merge({class: classes}), &)

      @template.content_tag("div", labels + field, {class: "field"})
    end

    private

    def text_like_field(field_method, object_method, options = {})
      custom_opts, opts = partition_custom_opts(options)

      classes = apply_style_classes(TEXT_FIELD_STYLE, custom_opts, object_method)

      field = send(field_method, object_method, {
        class: classes,
        title: errors_for(object_method)&.join(" ")
      }.compact.merge(opts).merge({tailwindified: true}))

      labels = labels(object_method, custom_opts[:label], options)

      @template.content_tag("div", labels + field, {class: "field"})
    end

    def labels(object_method, label_options, field_options)
      label = tailwind_label(object_method, label_options, field_options)
      error_label = error_label(object_method, field_options)

      label + error_label
    end

    def tailwind_label(object_method, label_options, field_options)
      text, label_opts = if label_options.present?
        [label_options[:text], label_options.except(:text)]
      else
        [nil, {}]
      end

      label_classes = label_opts[:class] || ""
      label_classes += " disabled" if field_options[:disabled]
      label(object_method, text, {
        class: label_classes
      }.merge(label_opts.except(:class)))
    end

    def error_label(object_method, options)
      if errors_for(object_method).present?
        error_message = @object.errors[object_method].collect(&:titleize).join(", ")
        tailwind_label(object_method, {text: error_message, class: "error_message"}, options)
      end
    end

    def border_color_classes(object_method)
      if errors_for(object_method).present?
        "has_error"
      end
    end

    def apply_style_classes(classes, custom_opts, object_method = nil)
      [
        classes,
        border_color_classes(object_method),
        custom_opts[:class]
      ].compact.join(" ")
    end

    CUSTOM_OPTS = [:label, :class].freeze

    def partition_custom_opts(opts)
      opts.partition { |k, v| CUSTOM_OPTS.include?(k) }.map(&:to_h)
    end

    def errors_for(object_method)
      return unless @object.present? && object_method.present?

      @object.errors[object_method]
    end
  end
end
