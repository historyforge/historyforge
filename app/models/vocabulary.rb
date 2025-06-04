# == Schema Information
#
# Table name: vocabularies
#
#  id           :bigint           not null, primary key
#  name         :string
#  machine_name :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_vocabularies_on_machine_name  (machine_name)
#

# frozen_string_literal: true

class Vocabulary < ApplicationRecord
  has_many :terms, dependent: :destroy
  validates :name, :machine_name, presence: true, uniqueness: { case_sensitive: false }
  default_scope -> { order :name }

  def term_exists?(term)
    terms.where("LOWER(name) = ?", term.downcase).exists?
  end

  def self.by_name(name)
    where(machine_name: name).first
  end

  def self.controlled_attribute_for(year, attribute)
    DICTIONARY.each do |vocab, years|
      years[year].each do |field|
        return by_name(vocab) if field.downcase == attribute.downcase
      end
    end
    nil
  end

  def fields_by_year
    DICTIONARY[machine_name.intern] || []
  end

  DICTIONARY = {
    language: {
      1850 => [],
      1860 => [],
      1870 => [],
      1880 => [],
      1900 => %w[language_spoken],
      1910 => %w[language_spoken],
      1920 => %w[mother_tongue mother_tongue_father mother_tongue_mother],
      1930 => %w[mother_tongue],
      1940 => %w[mother_tongue],
      1950 => %w[]
    },
    pob: {
      1850 => %w[pob],
      1860 => %w[pob],
      1870 => %w[pob],
      1880 => %w[pob pob_father pob_mother],
      1900 => %w[pob pob_father pob_mother],
      1910 => %w[pob pob_father pob_mother],
      1920 => %w[pob pob_father pob_mother],
      1930 => %w[pob pob_father pob_mother],
      1940 => %w[pob pob_father pob_mother],
      1950 => %w[pob pob_father pob_mother]
    },
    relation_to_head: {
      1850 => [],
      1860 => [],
      1870 => [],
      1880 => %w[relation_to_head],
      1900 => %w[relation_to_head],
      1910 => %w[relation_to_head],
      1920 => %w[relation_to_head],
      1930 => %w[relation_to_head],
      1940 => %w[relation_to_head],
      1950 => %w[relation_to_head]
    }
  }.freeze
end
