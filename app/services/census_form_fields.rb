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

  def self.halt(**options)
    self.fields ||= []
    self.inputs ||= {}
    fields << 'halt'
    inputs['halt'] = options.merge({ as: :halt })
  end

  def initialize(form)
    @fields = self.class.fields.dup
    @inputs = self.class.inputs.dup
    @form = form
  end

  def config_for(field)
    return unless form

    inputs[field]
  rescue StandardError => error
    Rails.logger.error "*** Field Config Missing for #{field}! ***"
    raise error
  end

  def render
    builder = if form.respond_to?(:supercrazy)
                JSONBuilder.new(form, resource_class)
              else
                FormBuilder.new(form)
              end

    fields.each do |field|
      config = config_for(field)
      case config[:as]
      when :halt
        # the purpose of this is to stop outputting supplemental form fields when viewing a 1940 record that
        # does not have them filled in
        return builder.to_html if form.is_a?(FormViewBuilder) && config[:if].call(form.object)
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

  # Outputs the form using Rails form builder which is passed in as @form
  class FormBuilder
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
      return true if config[:if] && !config[:if].call(form)
      return true if config[:edit_only] && form.is_a?(FormViewBuilder)
      return true if config[:view_only] && !form.is_a?(FormViewBuilder)

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
  end

  # Converts the census form into a format consumable by the "advanced search" filter button
  # using JBuilder object passed in as json
  class JSONBuilder
    def initialize(json, klass)
      @json = json
      @klass = klass
      @card = nil
    end

    attr_accessor :json, :card, :klass

    def start_card(title)
      @card = title
    end

    def add_field(field, config)
      return if card == 'Name'

      if config[:collection]
        collection = if config[:coded]
                       config[:collection].map do |item|
                         code = item.downcase == item ? item.capitalize : item
                         code = code.gsub('_', ' ')
                         label = translated_option item, field
                         code == label ? label : ["#{code} - #{translated_option(item, field)}", code]
                       end
                     else
                       config[:collection]
                     end
        AttributeBuilder.collection json, field, klass: klass, collection: collection
        return
      end

      case config[:as]
      when :number, :integer
        AttributeBuilder.number json, field, klass: klass
      when :boolean
        AttributeBuilder.boolean json, field, klass: klass
      when :radio_buttons
        AttributeBuilder.enumeration json, klass, field
      else
        AttributeBuilder.text json, field, klass: klass
      end
    end

    def to_html
      json
    end

    private

    def translated_option(item, field)
      Translator.option field, item
    end
  end
end
