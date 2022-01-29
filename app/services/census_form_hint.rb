# frozen_string_literal: true

# Generates the contents of the question mark hint bubbles on the census forms. Hint text comes from the
# census-hints.en.yml file. Column numbers and images currently live in the model files for each year because
# it didn't feel appropriate to use the translation system for those even though it would work.
class CensusFormHint
  def self.generate(form, field, type)
    new(form, field, type).generate
  end

  # Everything below here is private

  def initialize(form, field, type)
    @klass = form.object.class
    @template = form.template
    @year = form.object.year
    @field = field
    @type = type
  end

  def generate
    column.present? || text.present? ? "#{column}#{text}#{image}#{unknown}".html_safe : false
  end

  attr_reader :klass, :field, :type, :template, :year

  def column
    @column ||= formatted_column klass::COLUMNS[field]
  end

  def formatted_column(name)
    case name
    when nil
      nil
    when /-/
      "<u>Columns #{name}</u><br />"
    when String
      name.length > 1 ? "<u>#{name}</u><br />" : "<u>Column #{name}</u><br />"
    else
      "<u>Column #{name}</u><br />"
    end
  end

  def text
    @text ||= Translator.translate(klass, field, 'hints') ||
              Translator.translate(klass, type || 'string', 'hints')
  end

  def image
    img = klass::IMAGES[field]
    img && "<br />#{template.image_tag(img)}"
  end

  def unknown
    return if year >= 1940
    return if field =~ /name|head|house|page|line_|apartment|dwelling|family|occupation|profession|code/
    return unless %i[integer radio_buttons radio_buttons_other].include?(type) || type.blank?

    "<br /><hr />The scribble for &ldquo;Unknown&rdquo; often looks like this:<br />#{template.image_tag('unknown-scribble.png')}"
  end
end
