class VocabulariesController < ApplicationController
  before_action :check_administrator_role

  def index
    @vocabularies = Vocabulary.order(:name)
  end
end