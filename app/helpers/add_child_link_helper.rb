module AddChildLinkHelper

  ################################################################################
  #  Parent form
  # .nested-form
  #   .nested-form-items
  #     = form.fields_for {{object}} do |form2|
  #       = render '{{#partial}}', form: form2
  #     = add_child_link 'Add {{Object}}', form, :objects, object: {{Object instance}}.new, partial: '{{partial}}'
  # # Partial
  # .nested-form-item.{{object}}
  #   = form.input :...fields
  #   a.btn.btn-default.pull-right.remove &times;
  ################################################################################

  def new_child_fields(form_builder, method, options = {})
    options[:object] ||= form_builder.object.class.reflect_on_association(method).klass.new
    options[:partial] ||= method.to_s.singularize
    options[:form_builder_local] ||= :form
    options[:wrapper] ||= :vertical_form
    locals = options[:locals] || {}
    form_builder.fields_for(method, options[:object], :child_index => "new_#{method}") do |f|
      render options[:partial], locals.merge(options[:form_builder_local] => f)
    end
  end

  def add_child_link(name, f, method, *args)
    options = args.extract_options!
    fields = new_child_fields(f, method, options)
    content_for(:body_end) { content_tag(:script, fields, type: 'text/html', id: "#{method}_#{f.object_id}_fields") }
    content_tag(:button, name, 'data-form-selector' => options[:selector], 'data-insert-fields' => "#{method}_#{f.object_id}", class: "btn btn-primary add-child-button", type: 'button')
  end
end
