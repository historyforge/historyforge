# frozen_string_literal: true

module People
  class CensusHousehold
    Result = Data.define(:fellows, :head)

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
      # A hidden candidate still makes the head ambiguous.
      head = unique_head(candidates)
      Result.new(fellows:, head: (head if fellows.include?(head)))
    end

    private

    def unique_head(candidates)
      return unless @record.respond_to?(:relation_to_head) && @record.family_id.present? && @record.locality_id.present?

      heads = candidates.select do |fellow|
        fellow.relation_to_head.to_s.strip.casecmp?('head') && same_household_context?(fellow)
      end
      heads.first if heads.one?
    end

    def same_household_context?(fellow)
      return false unless @record.ward == fellow.ward
      return true if @record.building_id.present? || @record.dwelling_number.present?

      @record.page_number == fellow.page_number && @record.page_side == fellow.page_side
    end
  end
end
