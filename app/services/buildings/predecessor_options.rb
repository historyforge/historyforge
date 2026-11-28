# frozen_string_literal: true

module Buildings
  class PredecessorOptions
    def initialize(building, ability, locality_id: building.locality_id)
      @building = building
      @readable = Building.accessible_by(ability).where.not(id: building.id)
      @local = locality_id.present? ? @readable.where(locality_id:) : @readable.none
    end

    def suggestions
      candidates = nearby_buildings
      if candidates.empty? && @building.address&.name.present?
        ids = PossibleMatches.new(@building).buildings_on_street(scope: @local).map(&:id)
        candidates = @local.includes(:addresses).where(id: ids).index_by(&:id).values_at(*ids).compact
      end

      selected = @readable.includes(:addresses).find_by(id: @building.parent_id) if @building.parent_id
      ([selected].compact + candidates).uniq.map do |building|
        primary = building.primary_street_address.squish
        other_addresses = building.addresses.map { |address| address.address(place: nil).squish }.uniq - [primary]
        other_addresses.reject!(&:blank?)
        [label(primary, other_addresses.join(', ')), building.id]
      end
    end

    def search(term)
      term = term.to_s.squish
      return [] if term.length < 3

      pattern = "#{Address.sanitize_sql_like(term)}%"
      pattern = "%#{pattern}" unless term.match?(/\A[0-9]/)
      matches = Address.where(building_id: @local.select(:id))
                       .where("regexp_replace(trim(concat_ws(' ', house_number, prefix, name, suffix)), ' +', ' ', 'g') ILIKE ?", pattern)
                       .select('DISTINCT ON (building_id) addresses.*')
                       .order(:building_id, is_primary: :desc, id: :asc).limit(15).to_a
      buildings = @local.includes(:addresses).where(id: matches.map(&:building_id)).index_by(&:id)

      matches.filter_map do |address|
        building = buildings[address.building_id]
        next unless building

        primary = building.primary_street_address.squish
        matched = address.address(place: nil).squish unless address.is_primary?
        { id: building.id, name: label(primary, matched) }
      end
    end

    private

    def nearby_buildings
      return [] unless @building.geocoded?

      ids = @building.nearbys(0.03).map(&:id)
      @local.includes(:addresses).where(id: ids).index_by(&:id).values_at(*ids).compact
    end

    def label(primary, historical)
      historical.present? ? "#{primary} (also recorded as #{historical})" : primary
    end
  end
end
