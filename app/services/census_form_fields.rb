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

  def self.divider(title)
    self.fields ||= []
    self.inputs ||= {}
    fields << title
    inputs[title] = { as: :divider, label: title }
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
      if config[:as] == :divider
        builder.start_card(config[:label])
      else
        builder.add_field(field, config)
      end
    end
    builder.to_html
  end

  def resource_class
    @resource_class ||= self.class.to_s.sub(/FormFields/, 'Record').sub('Supplemental', '').constantize
  end

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

  class FormBuilder
    def initialize(form)
      @form = form
      @cards = []
    end
    attr_accessor :form

    def start_card(title)
      @cards << Card.new(title)
    end

    def add_field(field, config)
      if config[:hint]&.respond_to?(:call)
        config[:hint] = form.template.instance_exec &config[:hint]
      end

      @cards.last << form.input(field, config).html_safe
    end

    def to_html
      @cards.map { |card| form.card(card.to_h).html_safe }.join.html_safe
    end
  end

  class JSONBuilder
    def initialize(json, klass)
      @json = json
      @klass = klass
      @card = nil
      # add name and address fields to start
      AttributeBuilder.collection json, klass,:locality_id, Locality.select_options
      AttributeBuilder.text(json, :name, klass: klass)
      AttributeBuilder.text   json, :first_name, klass: klass
      AttributeBuilder.text   json, :middle_name, klass: klass
      AttributeBuilder.text   json, :last_name, klass: klass
      json.census_scope do
        json.label 'Census Schedule'
        json.sortable 'census_scope'
      end

      AttributeBuilder.number json, :page_number, klass: klass
      AttributeBuilder.enumeration json, klass, :page_side
      AttributeBuilder.number json, :line_number, sortable: false, klass: klass
      AttributeBuilder.text   json, :county, klass: klass
      AttributeBuilder.text   json, :city, klass: klass
      AttributeBuilder.number json, :ward, klass: klass
      AttributeBuilder.number json, :enum_dist, klass: klass
      AttributeBuilder.text   json, :street_address, klass: klass
      AttributeBuilder.text   json, :dwelling_number, klass: klass unless klass == Census1940Record
      AttributeBuilder.text   json, :family_id, klass: klass

      AttributeBuilder.boolean json, :foreign_born, klass: klass
      AttributeBuilder.text json, :notes, klass: klass
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
        AttributeBuilder.collection json, klass, field, collection
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
      I18n.t("#{field}.#{item.downcase.gsub(/\W/, '')}", scope: 'census_codes', default: item)
    end
  end
end
