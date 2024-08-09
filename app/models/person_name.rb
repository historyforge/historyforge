# frozen_string_literal: true

# == Schema Information
#
# Table name: person_names
#
#  id              :bigint           not null, primary key
#  person_id       :bigint           not null
#  is_primary      :boolean
#  last_name       :string
#  first_name      :string
#  middle_name     :string
#  name_prefix     :string
#  name_suffix     :string
#  searchable_name :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  sortable_name   :string
#
# Indexes
#
#  index_person_names_on_person_id        (person_id)
#  index_person_names_on_searchable_name  (searchable_name) USING gist
#  person_names_primary_name_index        (person_id,is_primary)
#
class PersonName < ApplicationRecord
  using NameCleaning

  belongs_to :person

  before_validation :clean_name
  before_save :set_searchable_name

  validates :first_name, :last_name, presence: true

  after_commit :audit_new_name, on: :create
  after_commit :audit_name_change, on: :update
  after_commit :audit_name_removal, on: :destroy

  def name
    [first_name, last_name].compact_blank.join(' ')
  end

  def previous_name
    [first_name_was, last_name_was].compact_blank.join(' ')
  end

  def set_searchable_name
    self.searchable_name = name
    self.sortable_name = [last_name, first_name].join(' ')
  end

  def clean_name
    %i[first_name last_name].each do |attribute|
      self[attribute] = self[attribute].clean if self[attribute]
    end
  end

  # @param record [Person, PersonName]
  # @ return [Boolean]
  def same_name_as?(record)
    (record.first_name == first_name &&
      record.last_name == last_name &&
      record.middle_name == middle_name &&
      record.name_prefix == name_prefix &&
      record.name_suffix == name_suffix) || record.name == name
  end

  def audit_new_name
    return if same_name_as?(person)

    person.audit_logs.create(message: "Name variant added: \"#{name}\"", logged_at: created_at)
  end

  def audit_name_change
    return unless saved_change_to_first_name? || saved_change_to_last_name?

    message = "Name variant \"#{previous_name}\" changed to \"#{name}\"."
    person.audit_logs.create(message:, logged_at: Time.current)
  end

  def audit_name_removal
    return if person.destroyed? || @skip_removal_audit

    message = "Name variant removed: \"#{name}\"."
    person.audit_logs.create(message:, logged_at: Time.current)
  end

  def skip_removal_audit!
    @skip_removal_audit = true
  end
end
