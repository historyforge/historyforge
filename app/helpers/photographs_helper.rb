# frozen_string_literal: true

module PhotographsHelper
  def thumb_for(file)
    return unless file.attached?

    image_tag file.variant(resize_to_fit: [300, 300]), class: 'img img-thumbnail'
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    nil
  end
end
