module FormViewHelper

  def view_for(record, options = {}, &block)
    raise ArgumentError, "Missing block" unless block_given?
    html_options = options[:html] ||= {}
    html_options[:class] ||= ''
    html_options[:class] << ' readonly-form'
    html_options[:class] = html_options[:class].strip

    case record
      when String, Symbol
        object_name = record
        object      = nil
      else
        object      = record.is_a?(Array) ? record.last : record
        object_name = model_name_from_record_or_class(object).param_key
    end
    builder = FormViewBuilder.new(object_name, object, self, options)
    output  = capture(builder, &block)

    content_tag(:div, html_options) { output }
  end

end

class FormViewBuilder < SimpleForm::FormBuilder

  def initialize(*) #:nodoc:
    super
    @default_options = { readonly: true }
  end

  def input(attribute_name, options = {}, &block)
    options = @defaults.deep_dup.deep_merge(options) if @defaults
    options[:required] = false
    input = find_input(attribute_name, options, &block)
    wrapper_name = case input.input_type
                   when :boolean then :horizontal_boolean
                   when :check_boxes then :horizontal_collection
                   when :date then :horizontal_multi_select
                   when :radio_buttons then :horizontal_collection
                   else
                     :horizontal_form
                   end

    wrapper = SimpleForm.wrapper wrapper_name
    wrapper.render input
  end

  def fields_for(record_name, record_object = nil, fields_options = {}, &block)
    fields_options[:builder] = options[:builder] || FormViewBuilder
    super
  end

  def label(method, text = nil, options = {}, &block)
    @template.content_tag(:div, text, class: 'col-sm-6 col-form-label')
  end

  def hidden_field(method, options = {}); end

  def file_field(method, options = {}); end

  def submit(value=nil, options={}); end

  def format_text(text)
    text =~ /\n/m ? "<br>".html_safe + @template.simple_format(text) : text
  end

  def content_tag(*args)
    @template.content_tag *args
  end


  def card(options)
    @template.census_card_show options
  end
end

SimpleForm::FormBuilder.class_eval do
  def card(options)
    @template.census_card_edit options
  end
end
