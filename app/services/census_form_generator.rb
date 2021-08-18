# frozen_string_literal: true

# Outputs the form using Rails form builder which is passed in as @form
class CensusFormGenerator
  def self.generate(form, config)
    new(form, config).render
  end

  def initialize(form, config)
    @form = form
    @config = config
    @cards = []
  end

  def render
    config.fields.each do |field|
      options = config.options_for(field)
      options[:as] == :divider ? start_card(options) : add_field(field, options)
    end
    to_html
  end

  private

  attr_accessor :form, :config

  def start_card(options)
    return if skip_me?(options)

    @cards << Card.new(options[:label])

    @cards.last << "<p style=\"flex-basis: 100%; margin-left: 1.125rem\">#{options[:hint]}</p>".html_safe if options[:hint]
  end

  def add_field(field, options)
    return if skip_me?(options)

    apply_options_for field, options
    @cards.last << form.input(field, **options).html_safe
  end

  def to_html
    @cards.map { |card| form.card(card.to_h).html_safe }.join.html_safe
  end

  def skip_me?(options)
    return true if options[:edit_only] && form.is_a?(FormViewBuilder)
    return true if options[:view_only] && !form.is_a?(FormViewBuilder)
    return true if options[:if] && !options[:if].call(form)

    false
  end

  def apply_options_for(field, options)
    options[:hint] = options.key?(:hint) ? options[:hint] : hint_for(field, options[:as])
    options.delete :placeholder
    options[:wrapper_html] = { data: { dependents: 'true' } } if options[:dependents]
    options[:wrapper_html] = { data: { depends_on: options[:depends_on] } } if options[:depends_on]
    if options[:min] || options[:max]
      options[:input_html] ||= {}
      options[:input_html].merge!({ min: options[:min] }) unless options[:min].nil?
      options[:input_html].merge!({ max: options[:max] }) unless options[:max].nil?
    end

    if options[:as] == :boolean
      options[:inline_label] ||= 'Yes'
    elsif %i[select radio_buttons radio_buttons_other].include?(options[:as])
      options[:collection] = options[:collection].call(form) if options[:collection].respond_to?(:call)
    elsif options[:as].blank?
      options[:input_html] ||= {}
      options[:input_html].merge!(autocomplete: :off, 'data-controller': 'census-autocomplete')
    end
  end

  def hint_for(field, type)
    CensusFormHint.generate form, field, type
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
