# frozen_string_literal: true

task migrate_annotations: :environment do
  layer = MapOverlay.find 21 # insert the id of your default map overlay here
  Building.find_each do |building|
    next if building.annotations_legacy.blank?

    Annotation.find_or_create_by! building_id: building.id,
                                  map_overlay_id: layer.id,
                                  annotation_text: building.annotations_legacy
  end
end

def print_usage(description)
  mb = GetProcessMem.new.mb
  puts "#{ description } - MEMORY USAGE(MB): #{ mb.round }"
end

def print_usage_before_and_after
  print_usage("Before")
  yield
  print_usage("After")
end

task perf: :environment do
  require 'get_process_mem'

  params = {
    f: %w[ward enum_dist page_number page_side name street_address race sex age marital_status],
    s: {
      street_address_cont: 'Tioga'
    },
    c: 'name',
    d: 'desc'
  }
  data = CensusRecordSearch.generate year: 1940, user: nil, params: params
  translator = CensusGridTranslator.new data

  output = translator.row_data.lazy

  print_usage_before_and_after do
    puts "-> Oj.dump"
    Oj.dump output
  end

  print_usage_before_and_after do
    puts "-> to_json"
    output.to_json
  end
end
