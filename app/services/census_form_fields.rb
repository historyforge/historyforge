# frozen_string_literal: true

class CensusFormFields
  class_attribute :inputs, :fields

  attr_accessor :inputs, :fields, :form

  def self.input(field, **options)
    self.fields ||= []
    self.inputs ||= {}
    fields << field
    options[:inline_label] = 'Yes' if options[:as] == :boolean
    inputs[field] = options
  end

  def self.divider(title, **options)
    self.fields ||= []
    self.inputs ||= {}
    fields << title
    inputs[title] = options.merge({ as: :divider, label: title })
  end

  def self.json(form)
    service = new(form)
    service.builder = CensusJsonBuilder.new(form, service.resource_class)
    service.render
  end

  def self.html(form)
    service = new(form)
    service.builder = CensusFormBuilder.new(form)
    service.render
  end

  def initialize(form)
    @fields = self.class.fields.dup
    @inputs = self.class.inputs.dup
    @form = form
  end

  attr_accessor :builder

  def config_for(field)
    return unless form

    inputs[field]
  rescue StandardError => error
    Rails.logger.error "*** Field Config Missing for #{field}! ***"
    raise error
  end

  def render
    fields.each do |field|
      config = config_for(field)
      case config[:as]
      when :divider
        builder.start_card(config)
      else
        builder.add_field(field, config)
      end
    end
    builder.to_html
  end

  def resource_class
    @resource_class ||= self.class.to_s.sub(/FormFields/, 'Record').safe_constantize
  end
end
