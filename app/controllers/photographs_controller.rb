# frozen_string_literal: true

class PhotographsController < MediaController
  self.model_class = Photograph
  self.model_association = :photos
end
