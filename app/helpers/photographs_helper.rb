module PhotographsHelper
  def thumb_for(photo)
    return unless photo.file.attached?
    image_tag photo.file.variant(resize_to_fit: [300, 300]), class: 'img img-thumbnail'
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    nil
  end

  def review_error_messages_for(*objects)
    options = objects.extract_options!
    options[:header_message] ||= I18n.t(:"activerecord.errors.header", :default => "Review Status")
    options[:message] ||= I18n.t(:"activerecord.errors.message", :default => "Things to do before we can mark this as reviewed:")
    messages = objects.compact.map { |o| o.errors.full_messages }.flatten
    unless messages.empty?
      content_tag(:div, :class => "alert alert-info") do
        list_items = messages.map { |msg| content_tag(:li, msg) }
        content_tag(:h4, options[:header_message]) + content_tag(:p, options[:message]) + content_tag(:ul, list_items.join.html_safe)
      end
    end
  end

end