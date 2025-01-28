module FormBuilders
  class NiceFormBuilder < ActionView::Helpers::FormBuilder
    class_attribute :text_field_helpers,
      default: field_helpers - %i[
        label
        check_box
        radio_button
        fields_for
        fields
        hidden_field
        file_field
      ]

    TEXT_FIELD_STYLE = "text_field".freeze
    TEXT_AREA_STYLE = "textarea_field".freeze
    SELECT_FIELD_STYLE = "select_field".freeze
    SUBMIT_BUTTON_STYLE = "primary_button".freeze
    CHECKBOX_FIELD_STYLE = "checkbox_group".freeze
    DATE_SELECT_STYLE = "date_select".freeze
    TIME_SELECT_STYLE = "time_select".freeze

    text_field_helpers.each do |field_method|
      define_method(field_method) do |method, options = {}|
        if options.delete(:already_nice)
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

    def select(method, choices = nil, options = {}, html_options = {}, &block)
      custom_opts, opts = partition_custom_opts(options)
      classes = apply_style_classes(SELECT_FIELD_STYLE, custom_opts, method)

      labels = labels(method, custom_opts[:label], options)
      field = super(
        method,
        choices,
        opts,
        html_options.merge({class: classes}),
        &block
      )

      @template.content_tag("div", labels + field, {class: "field"})
    end

    def collection_checkboxes(
      method,
      collection,
      value_method,
      text_method,
      options = {},
      html_options = {},
      &block
    )
      custom_opts, opts = partition_custom_opts(options)

      classes = apply_style_classes(
        CHECKBOX_FIELD_STYLE,
        custom_opts,
        method
      )

      labels = labels(method, custom_opts[:label], options)

      html_options = html_options.merge(class: classes)

      check_boxes = super(
        method,
        collection,
        value_method,
        text_method,
        opts,
        html_options,
        &block
      )

      @template.content_tag(
        "div",
        labels + check_boxes,
        {class: "field"}
      )
    end

    def date_select(method, options = {}, html_options = {})
      custom_opts, opts = partition_custom_opts(options)
      classes = apply_style_classes(nil, custom_opts, method)

      labels = labels(method, custom_opts[:label], options)
      field = @template.content_tag("div",
        super(method, opts, html_options.merge(class: classes)),
        {class: "flex flex-row gap-4"})

      @template.content_tag("div", labels + field, {class: "field"})
    end

    def time_select(method, options = {}, html_options = {})
      custom_opts, opts = partition_custom_opts(options)
      classes = apply_style_classes(nil, custom_opts, method)

      labels = labels(method, custom_opts[:label], options)
      field = @template.content_tag("div",
        super(method, opts, html_options.merge(class: classes)),
        {class: "flex flex-row gap-4"})

      @template.content_tag("div", labels + field, {class: "field"})
    end

    private

    def text_like_field(field_method, object_method, options = {})
      custom_opts, opts = partition_custom_opts(options)
      style = (field_method == :text_area) ? TEXT_AREA_STYLE : TEXT_FIELD_STYLE
      classes = apply_style_classes(style, custom_opts, object_method)

      field_options = {
        class: classes,
        title: errors_for(object_method)&.join(" ")
      }.compact.merge(opts).merge(already_nice: true)

      field = send(field_method, object_method, field_options)
      labels = labels(object_method, custom_opts[:label], options)

      @template.content_tag("div", labels + field, {class: "field"})
    end

    def labels(object_method, label_options, field_options)
      label = nice_label(object_method, label_options, field_options)
      error_label = error_label(object_method, field_options)

      label + error_label
    end

    def nice_label(object_method, label_options, field_options)
      text, label_opts = label_options.present? ? label_options.values_at(:text, :except) : [nil, {}]
      label_opts ||= {}

      label_classes = label_opts[:class].to_s
      label_classes += " disabled" if field_options[:disabled]

      label(object_method, text, {
        class: label_classes.strip
      }.merge(label_opts.except(:class)))
    end

    def error_label(object_method, options)
      return if errors_for(object_method).blank?

      error_message = @object.errors[object_method].collect(&:titleize).join(", ")
      nice_label(object_method, {text: error_message, class: "error_message"}, options)
    end

    def border_color_classes(object_method)
      return "" unless object_method
      "has_error" if errors_for(object_method).present?
    end

    def apply_style_classes(base_class, custom_opts, object_method = nil)
      [
        base_class,
        border_color_classes(object_method),
        custom_opts[:class]
      ].compact.join(" ")
    end

    CUSTOM_OPTS = [:label, :class].freeze

    def partition_custom_opts(opts)
      opts.partition { |k, _| CUSTOM_OPTS.include?(k) }.map(&:to_h)
    end

    def errors_for(object_method)
      return unless @object.present? && object_method.present?

      @object.errors[object_method]
    end
  end
end
