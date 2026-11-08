# frozen_string_literal: true

module People
  class CensusHousehold
    Result = Data.define(:fellows, :head, :members)

    def self.call(record:, readable:)
      new(record:, readable:).call
    end

    def initialize(record:, readable:)
      @record = record
      @readable = readable
    end

    def call
      candidates = @record.fellows.to_a
      fellows = candidates.select(&@readable)
      members = []
      head = nil
      if @record.family_id.present? && @record.locality_id.present?
        context = candidates.select { |fellow| same_household_context?(fellow) }
        heads = [@record, *context].select { |row| row.try(:relation_to_head).to_s.strip.casecmp?('head') }
        # An unreadable head still counts when checking for ambiguity.
        if heads.size <= 1
          members = fellows & context
          head = heads.first if members.include?(heads.first)
        end
      end
      Result.new(fellows:, head:, members:)
    end

    private

    def same_household_context?(fellow)
      return false unless @record.ward == fellow.ward
      return true if @record.building_id.present? || @record.dwelling_number.present?

      @record.page_number == fellow.page_number && @record.page_side == fellow.page_side
    end
  end
end
