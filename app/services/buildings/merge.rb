# frozen_string_literal: true

module Buildings
  class Merge < ApplicationInteraction
    object :source, class: 'Building'
    object :target, class: 'Building'

    def execute
      merge_census_records
      merge_addresses
      merge_building_data
      merge_photographs
      target.save!
      source.destroy!
      BuildAddressHistory.new(target).perform
      target.audit_logs.create message: "Merged ##{source.id} - #{source.name}"
    end

    private

    def validate_distance
      errors.add(:base, 'Buildings are too far apart to merge.') if distance > 0.015
    end

    def distance
      Geocoder::Calculations.distance_between(source, target)
    end

    def merge_addresses
      source.addresses.each do |address|
        next if target.addresses.any? { |addr| addr.equals?(address) }

        address.update(building_id: target.id, is_primary: false)
      end
      target.addresses.reload
    end

    def merge_building_data
      source.attributes.keys.each do |attr|
        next if attr =~ /created|updated|reviewed|address|name/
        create_or_append(attr)
      end
      target.name = source.name if target.name.blank?
      create_or_append(:architect_ids)
    end

    def merge_census_records
      CensusYears.each do |year|
        "Census#{year}Record".constantize.where(building_id: source.id).each do |record|
          record.update(building_id: target.id)
        end
      end
    end

    def merge_photographs
      @source.photos.each do |photo|
        photo.buildings << @target
      end
    end

    def create_or_append(field)
      source_val = @source.send(field)
      target_val = @target.send(field)
      return if source_val.blank? || source_val == target_val

      if target_val.blank?
        @target.send(:"#{field}=", source_val)
      elsif source_val.is_a?(String)
        @target.send(:"#{field}=", [target_val, source_val].join("\r\n"))
      elsif source_val.is_a?(Array)
        @target.send(:"#{field}=", target_val.concat(source_val).uniq)
      end
    end
  end
end
