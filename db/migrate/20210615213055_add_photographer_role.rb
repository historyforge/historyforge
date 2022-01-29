# frozen_string_literal: true

class AddPhotographerRole < ActiveRecord::Migration[6.0]
  def change
    Role.find_or_create_by name: 'photographer'
  end
end
