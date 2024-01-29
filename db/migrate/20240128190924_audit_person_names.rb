# frozen_string_literal: true

class AuditPersonNames < ActiveRecord::Migration[7.0]
  def down
    # do nothing
  end
  def up
    PersonName.update_all(is_primary: false)
    PersonName.where(first_name: %w[Mr Mrs]).update_all(first_name: nil)

    Person.preload(:names).find_each do |person|
      # If the names have info, esp middle name, suffix, or prefix, that aren't part of the primary name, add it here.
      person.names.each do |name|
        person.middle_name ||= name.middle_name if name.middle_name.present?
        person.name_prefix ||= name.name_prefix if name.name_prefix.present?
        person.name_suffix ||= name.name_suffix if name.name_suffix.present?
      end
      person.save if person.changed?

      # Make sure the primary name exists and matches the name on the person record.
      primary_name = person.names.detect { |name| name.first_name == person.first_name && name.last_name == person.last_name }
      if primary_name
        primary_name.audit_new_name
        primary_name.update(
          name_prefix: nil,
          name_suffix: nil,
          middle_name: nil,
          first_name: person.first_name,
          last_name: person.last_name
        )
      else
        primary_name = person.names.create(first_name: person.first_name, last_name: person.last_name)
      end

      # Now remove any other name records that have the same first and last name.
      person.names.each do |name|
        next if primary_name.id == name.id

        # If the first name is different, keep the variant
        first_name_same = name.first_name.present? && person.first_name.present? && person.first_name.casecmp(name.first_name).zero?

        # If the last name is different, keep the variant
        last_name_same = name.last_name.present? && person.last_name.present? && person.last_name.casecmp(name.last_name).zero?

        if first_name_same && last_name_same
          name.destroy
        else
          name.audit_new_name
        end
      end
    end
  end
end
