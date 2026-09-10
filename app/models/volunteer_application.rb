# frozen_string_literal: true

class VolunteerApplication < ApplicationRecord
  STATUSES = %w[submitted contacted accepted declined archived].freeze
  EXPERIENCE_OPTIONS = %w[yes no maybe].freeze

  OPPORTUNITIES = {
    'transcribing' => 'Transcribing historical records',
    'research' => 'Researching people, buildings, and neighborhoods',
    'maps' => 'Working with historic maps',
    'media' => 'Finding and describing photographs and other media',
    'connecting_sources' => 'Connecting records, photographs, and other historical sources',
    'writing' => 'Writing stories or other historical content',
    'data_review' => 'Helping review or improve existing HistoryForge data',
    'outreach' => 'Outreach, events, or community engagement',
    'technical' => 'Technical or digital project work',
    'internship' => 'Student internship',
    'other' => 'Other',
  }.freeze
  belongs_to :user, optional: true
  normalizes :locality_names, :opportunity_interests, with: ->(values) { Array(values).reject(&:blank?).uniq }
  validate :valid_opportunity_interests, if: :will_save_change_to_opportunity_interests?

  def opportunity_labels
    opportunity_interests.map { |code| OPPORTUNITIES.fetch(code, code) }
  end

  normalizes :email, with: ->(email) { email.strip.downcase }
  normalizes :experience, with: ->(value) { value.presence }
  validates :name, :email, :how_heard, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, inclusion: { in: STATUSES }
  validates :experience, inclusion: { in: EXPERIENCE_OPTIONS }, allow_nil: true
  private

  def valid_opportunity_interests
    allowed = OPPORTUNITIES.keys
    errors.add(:opportunity_interests, 'contains an unavailable choice') if (opportunity_interests - allowed).any?
  end


end
