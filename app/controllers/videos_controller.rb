# frozen_string_literal: true

class VideosController < MediaController
  self.model_class = Video
  self.model_association = :videos
end
