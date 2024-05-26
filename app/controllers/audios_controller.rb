# frozen_string_literal: true

class AudiosController < MediaController
  self.model_class = Audio
  self.model_association = :audios
end
