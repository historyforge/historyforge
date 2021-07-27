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
        builder.start_card(config[:label])
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

    def start_card(title)
      @cards << Card.new(title)
    end

    def add_field(field, config)
      config[:hint] = form.template.instance_exec &config[:hint] if config[:hint].respond_to?(:call)

      @cards.last << form.input(field, config).html_safe
    end

    def to_html
      @cards.map { |card| form.card(card.to_h).html_safe }.join.html_safe
    end
  end

  # Converts the census form into a format consumable by the "advanced search" filter button
  # using JBuilder object passed in as json
  class JSONBuilder
    def initialize(json, klass)
      @json = json
      @klass = klass
      @card = nil
      # add name and address fields to start
      output_common_fields(json, klass)

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

    def output_common_fields(json, klass)
      AttributeBuilder.text(json, :name, klass: klass)
      AttributeBuilder.text json, :street_address, klass: klass
      AttributeBuilder.text json, :first_name, klass: klass
      AttributeBuilder.text json, :middle_name, klass: klass
      AttributeBuilder.text json, :last_name, klass: klass
      AttributeBuilder.text json, :county, klass: klass
      AttributeBuilder.text json, :city, klass: klass
      AttributeBuilder.number json, :ward, klass: klass
      AttributeBuilder.number json, :page_number, klass: klass
      AttributeBuilder.enumeration json, klass, :page_side
      AttributeBuilder.number json, :line_number, sortable: false, klass: klass
      AttributeBuilder.number json, :enum_dist, klass: klass
      AttributeBuilder.text json, :dwelling_number, klass: klass unless klass == Census1940Record
      AttributeBuilder.text json, :family_id, klass: klass
      AttributeBuilder.collection json, :locality_id, klass: klass, collection: Locality.select_options
      AttributeBuilder.text json, :notes, klass: klass
    end

    def translated_option(item, field)
      Translator.option field, item
    end
  end
end
