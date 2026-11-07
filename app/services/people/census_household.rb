# frozen_string_literal: true

module People
  CensusHousehold = Data.define(:fellows, :head) do
    def self.load(record, readable:)
      candidates = record.fellows.to_a
      fellows = candidates.select(&readable)
      # A hidden candidate still makes the head ambiguous.
      head = unique_head(record, candidates)
      new(fellows:, head: (head if fellows.include?(head)))
    end

    def self.unique_head(record, candidates)
      return unless record.respond_to?(:relation_to_head) && record.family_id.present? && record.locality_id.present?

      heads = candidates.select do |fellow|
        fellow.relation_to_head.to_s.strip.casecmp?('head') &&
          record.ward == fellow.ward &&
          (record.building_id.present? || record.dwelling_number.present? ||
           (record.page_number == fellow.page_number && record.page_side == fellow.page_side))
      end
      heads.first if heads.one?
    end
    private_class_method :unique_head
  end
end
