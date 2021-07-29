# frozen_string_literal: true

module PhotographsHelper
  def thumb_for(photo)
    return unless photo.file.attached?
    image_tag photo.file.variant(resize_to_fit: [300, 300]), class: 'img img-thumbnail'
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    nil
  end

  def review_error_messages_for(*objects)
    error_messages_for *objects,
                       header_message: 'Review Status',
                       message: 'Things to do before we can mark this as reviewed:'
  end

end