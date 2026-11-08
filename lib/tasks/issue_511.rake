# frozen_string_literal: true

require 'csv'

namespace :historyforge do
  desc 'Preview or explicitly apply the reviewed Ithaca building name repair for issue #511'
  task repair_ithaca_building_names: :environment do
    database = Building.connection.select_value('SELECT current_database()')
    apply = ENV['APPLY'] == '1'
    allowed_databases = apply ? %w[ithaca] : %w[ithaca ithaca_20261108]
    abort "Issue #511 repair is restricted to Ithaca (connected to #{database.inspect})" unless allowed_databases.include?(database)

    rows = CSV.read(ENV.fetch('REVIEWED_CSV'), headers: true)
    required_columns = %w[building_id current_name proposed_name disposition primary_address_id]
    abort 'Expected a reviewed issue #511 CSV' unless (required_columns - rows.headers).empty? && rows.any?
    abort 'Duplicate building IDs in reviewed CSV' unless rows.map { |row| row['building_id'] }.uniq.size == rows.size

    counts = Hash.new(0)
    Building.transaction do
      rows.each do |row|
        id = Integer(row['building_id'], 10)
        building = (apply ? Building.lock : Building).find_by(id: id)
        if building.nil? || building.name != row['current_name']
          puts "Skip #{id}: building missing or stored name changed"
          counts[:skipped] += 1
          next
        end

        primary_addresses = building.addresses.select(&:is_primary?)
        if !primary_addresses.one? || primary_addresses.first.id.to_s != row['primary_address_id']
          puts "Skip #{id}: primary address changed"
          counts[:skipped] += 1
          next
        end

        case row['disposition']
        when 'regenerate'
          building.name = nil
          building.name_the_house
        when 'preserve_named_building'
          abort "Unexpected custom name for building #{id}" unless id == 10153 && row['proposed_name'] == 'Forest Home School / Garage'

          building.name = row['proposed_name']
        else
          abort "Unexpected disposition for building #{id}: #{row['disposition'].inspect}"
        end

        if building.name.blank? || building.name != row['proposed_name']
          puts "Skip #{id}: generated name differs from reviewed proposal"
          counts[:skipped] += 1
          next
        end

        puts "#{id}: #{row['current_name'].inspect} -> #{building.name.inspect}"
        building.update!(comment: 'Ithaca building name repair (#511)') if apply
        counts[:matched] += 1
      end
    end

    puts "#{database}: #{counts[:matched]} #{apply ? 'updated' : 'would update'}, #{counts[:skipped]} skipped"
  end
end
