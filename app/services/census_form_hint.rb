class CensusFormHint
  def self.generate(form, field, type)
    new(form, field, type).generate
  end

  def initialize(form, field, type)
    @klass = form.object.class
    @template = form.template
    @field = field
    @type = type
  end

  def generate
    column.present? || text.present? ? "#{column}#{text}#{image}#{unknown}".html_safe : false
  end

  attr_reader :klass, :field, :type, :template

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
    img && "<br />#{template.image_pack_tag(img)}"
  end

  def unknown
    return unless field !~ /name|head/ && (%i[integer radio_buttons radio_buttons_other].include?(type) || type.blank?)

    "<br />The scribble for &ldquo;Unknown&rdquo; often looks like this:<br />#{template.image_pack_tag('unknown-scribble.png')}"
  end
end
