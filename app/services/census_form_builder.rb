# frozen_string_literal: true

# Outputs the form using Rails form builder which is passed in as @form
class CensusFormBuilder
  def initialize(form)
    @form = form
    @cards = []
  end
  attr_accessor :form

  def start_card(config)
    return if skip_me?(config)

    @cards << Card.new(config[:label])
  end

  def add_field(field, config)
    return if skip_me?(config)

    apply_config_for field, config
    @cards.last << form.input(field, **config).html_safe
  end

  def to_html
    @cards.map { |card| form.card(card.to_h).html_safe }.join.html_safe
  end

  def skip_me?(config)
    return true if config[:edit_only] && form.is_a?(FormViewBuilder)
    return true if config[:view_only] && !form.is_a?(FormViewBuilder)
    return true if config[:if] && !config[:if].call(form)

    false
  end

  def apply_config_for(field, config)
    config[:hint] = hint_for(field)
    config.delete :placeholder
    config[:wrapper_html] = { data: { dependents: 'true' } } if config[:dependents]
    config[:wrapper_html] = { data: { depends_on: config[:depends_on] } } if config[:depends_on]
    if config[:min] || config[:max]
      config[:input_html] ||= {}
      config[:input_html].merge!({ min: config[:min] }) unless config[:min].nil?
      config[:input_html].merge!({ max: config[:max] }) unless config[:max].nil?
    end

    if config[:as] == :boolean
      config[:inline_label] ||= 'Yes'
    elsif %i[select radio_buttons radio_buttons_other].include?(config[:as])
      config[:collection] ||= form.object.class.try(:"#{field}_choices")
      config[:collection] = config[:collection].call(form) if config[:collection].respond_to?(:call)
    elsif config[:as].blank?
      config[:input_html] ||= {}
      config[:input_html].merge! autocomplete: :off
    end
  end

  def hint_for(field)
    column = Translator.translate(form.object.class, field, 'columns')
    text   = Translator.translate(form.object.class, field, 'hints')

    column = "<u>Column #{column}</u><br /><br />" if column

    column.present? || text.present? ? "#{column}#{text}".html_safe : false
  end

  # Card will group its inputs into a bootstrap card with the title as the header
  class Card
    def initialize(title)
      @title = title
      @list = []
    end
    attr_accessor :title, :list

    def to_h
      { title: title, list: list }
    end

    def <<(item)
      list << item
    end
  end
end
