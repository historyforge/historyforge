# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_09_05_173922) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "fuzzystrmatch"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.bigint "building_id", null: false
    t.boolean "is_primary", default: false
    t.string "house_number"
    t.string "prefix"
    t.string "name"
    t.string "suffix"
    t.string "city"
    t.string "postal_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "year"
    t.index ["building_id"], name: "index_addresses_on_building_id"
  end

  create_table "annotations", force: :cascade do |t|
    t.text "annotation_text"
    t.bigint "map_overlay_id"
    t.bigint "building_id"
    t.index ["building_id", "map_overlay_id"], name: "index_annotations_on_building_id_and_map_overlay_id", unique: true
    t.index ["building_id"], name: "index_annotations_on_building_id"
    t.index ["map_overlay_id"], name: "index_annotations_on_map_overlay_id"
  end

  create_table "architects", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "architects_buildings", id: false, force: :cascade do |t|
    t.integer "architect_id", null: false
    t.integer "building_id", null: false
    t.index ["architect_id", "building_id"], name: "architects_buildings_index", unique: true
  end

  create_table "building_types", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "buildings", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "city", null: false
    t.string "state", null: false
    t.string "postal_code"
    t.integer "year_earliest"
    t.integer "year_latest"
    t.integer "building_type_id"
    t.text "description"
    t.decimal "lat", precision: 15, scale: 10
    t.decimal "lon", precision: 15, scale: 10
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "year_earliest_circa", default: false
    t.boolean "year_latest_circa", default: false
    t.string "address_house_number"
    t.string "address_street_prefix"
    t.string "address_street_name"
    t.string "address_street_suffix"
    t.float "stories"
    t.text "annotations_legacy"
    t.integer "lining_type_id"
    t.integer "frame_type_id"
    t.string "block_number"
    t.integer "created_by_id"
    t.integer "reviewed_by_id"
    t.datetime "reviewed_at", precision: nil
    t.boolean "investigate", default: false
    t.string "investigate_reason"
    t.text "notes"
    t.bigint "locality_id"
    t.integer "building_types_mask"
    t.index ["building_type_id"], name: "index_buildings_on_building_type_id"
    t.index ["created_by_id"], name: "index_buildings_on_created_by_id"
    t.index ["frame_type_id"], name: "index_buildings_on_frame_type_id"
    t.index ["lining_type_id"], name: "index_buildings_on_lining_type_id"
    t.index ["locality_id"], name: "index_buildings_on_locality_id"
    t.index ["reviewed_by_id"], name: "index_buildings_on_reviewed_by_id"
  end

  create_table "buildings_building_types", id: false, force: :cascade do |t|
    t.bigint "building_id"
    t.bigint "building_type_id"
    t.index ["building_id", "building_type_id"], name: "buildings_building_types_unique_index", unique: true
    t.index ["building_id"], name: "index_buildings_building_types_on_building_id"
    t.index ["building_type_id"], name: "index_buildings_building_types_on_building_type_id"
  end

  create_table "buildings_photographs", id: false, force: :cascade do |t|
    t.bigint "photograph_id", null: false
    t.bigint "building_id", null: false
  end

  create_table "bulk_updated_records", force: :cascade do |t|
    t.bigint "bulk_update_id"
    t.string "record_type"
    t.bigint "record_id"
    t.index ["bulk_update_id"], name: "index_bulk_updated_records_on_bulk_update_id"
    t.index ["record_type", "record_id"], name: "index_bulk_updated_records_on_record_type_and_record_id"
  end

  create_table "bulk_updates", force: :cascade do |t|
    t.integer "year"
    t.string "field"
    t.string "value_from"
    t.string "value_to"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_bulk_updates_on_user_id"
  end

  create_table "census1950_records", force: :cascade do |t|
    t.bigint "locality_id"
    t.bigint "building_id"
    t.bigint "person_id"
    t.bigint "created_by_id"
    t.bigint "reviewed_by_id"
    t.datetime "reviewed_at"
    t.integer "page_number"
    t.string "page_side", limit: 1
    t.integer "line_number"
    t.string "county"
    t.string "city"
    t.string "state"
    t.integer "ward"
    t.integer "enum_dist"
    t.string "institution_name"
    t.string "institution_type"
    t.string "apartment_number"
    t.string "street_prefix"
    t.string "street_name"
    t.string "street_suffix"
    t.string "street_house_number"
    t.string "dwelling_number"
    t.string "family_id"
    t.boolean "lives_on_farm"
    t.boolean "lives_on_3_acres"
    t.string "ag_questionnaire_no"
    t.string "last_name"
    t.string "first_name"
    t.string "middle_name"
    t.string "name_prefix"
    t.string "name_suffix"
    t.text "searchable_name"
    t.string "relation_to_head"
    t.string "race"
    t.string "sex"
    t.integer "age"
    t.string "marital_status"
    t.string "pob"
    t.boolean "foreign_born", default: false
    t.string "naturalized_alien"
    t.string "activity_last_week"
    t.boolean "worked_last_week"
    t.boolean "seeking_work"
    t.boolean "employed_absent"
    t.integer "hours_worked"
    t.string "occupation", default: "None"
    t.string "industry"
    t.string "worker_class"
    t.string "occupation_code"
    t.string "industry_code"
    t.string "worker_class_code"
    t.boolean "same_house_1949"
    t.boolean "on_farm_1949"
    t.boolean "same_county_1949"
    t.string "county_1949"
    t.string "state_1949"
    t.string "pob_father"
    t.string "pob_mother"
    t.string "highest_grade"
    t.boolean "finished_grade"
    t.integer "weeks_seeking_work"
    t.integer "weeks_worked"
    t.string "wages_or_salary_self"
    t.string "own_business_self"
    t.string "unearned_income_self"
    t.string "wages_or_salary_family"
    t.string "own_business_family"
    t.string "unearned_income_family"
    t.boolean "veteran_ww2"
    t.boolean "veteran_ww1"
    t.boolean "veteran_other"
    t.boolean "item_20_entries"
    t.string "last_occupation"
    t.string "last_industry"
    t.string "last_worker_class"
    t.boolean "multi_marriage"
    t.integer "years_married"
    t.boolean "newlyweds"
    t.integer "children_born"
    t.text "notes"
    t.boolean "provisional", default: false
    t.boolean "taker_error", default: false
    t.uuid "histid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "birth_month"
    t.boolean "attended_school", default: false
    t.index ["building_id"], name: "index_census1950_records_on_building_id"
    t.index ["created_by_id"], name: "index_census1950_records_on_created_by_id"
    t.index ["locality_id"], name: "index_census1950_records_on_locality_id"
    t.index ["person_id"], name: "index_census1950_records_on_person_id"
    t.index ["reviewed_by_id"], name: "index_census1950_records_on_reviewed_by_id"
  end

  create_table "census_1880_records", force: :cascade do |t|
    t.bigint "locality_id"
    t.bigint "building_id"
    t.bigint "person_id"
    t.bigint "created_by_id"
    t.bigint "reviewed_by_id"
    t.datetime "reviewed_at", precision: nil
    t.integer "page_number"
    t.string "page_side", limit: 1
    t.integer "line_number"
    t.string "county"
    t.string "city"
    t.string "state"
    t.string "ward_str"
    t.string "enum_dist_str"
    t.string "street_house_number"
    t.string "street_prefix"
    t.string "street_name"
    t.string "street_suffix"
    t.string "apartment_number"
    t.string "dwelling_number"
    t.string "family_id"
    t.string "last_name"
    t.string "first_name"
    t.string "middle_name"
    t.string "name_prefix"
    t.string "name_suffix"
    t.string "sex"
    t.string "race"
    t.integer "age"
    t.integer "age_months"
    t.integer "birth_month"
    t.string "relation_to_head"
    t.string "marital_status"
    t.boolean "just_married"
    t.string "occupation", default: "None"
    t.integer "unemployed_months"
    t.string "sick"
    t.boolean "blind"
    t.boolean "deaf_dumb"
    t.boolean "idiotic"
    t.boolean "insane"
    t.boolean "maimed"
    t.boolean "attended_school"
    t.boolean "cannot_read"
    t.boolean "cannot_write"
    t.string "pob"
    t.string "pob_father"
    t.string "pob_mother"
    t.text "notes"
    t.boolean "provisional", default: false
    t.boolean "foreign_born", default: false
    t.boolean "taker_error", default: false
    t.integer "farm_schedule"
    t.text "searchable_name"
    t.uuid "histid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "enum_dist"
    t.integer "ward"
    t.index ["building_id"], name: "index_census_1880_records_on_building_id"
    t.index ["created_by_id"], name: "index_census_1880_records_on_created_by_id"
    t.index ["locality_id"], name: "index_census_1880_records_on_locality_id"
    t.index ["person_id"], name: "index_census_1880_records_on_person_id"
    t.index ["reviewed_by_id"], name: "index_census_1880_records_on_reviewed_by_id"
  end

  create_table "census_1900_records", id: :serial, force: :cascade do |t|
    t.jsonb "data"
    t.integer "building_id"
    t.integer "person_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "created_by_id"
    t.integer "reviewed_by_id"
    t.datetime "reviewed_at", precision: nil
    t.integer "page_number"
    t.string "page_side", limit: 1
    t.integer "line_number"
    t.string "county"
    t.string "city"
    t.string "state"
    t.string "ward_str"
    t.string "enum_dist_str"
    t.string "street_prefix"
    t.string "street_name"
    t.string "street_suffix"
    t.string "street_house_number"
    t.string "dwelling_number"
    t.string "family_id"
    t.string "last_name"
    t.string "first_name"
    t.string "middle_name"
    t.string "relation_to_head"
    t.string "sex"
    t.string "race"
    t.integer "birth_month"
    t.integer "birth_year"
    t.integer "age"
    t.string "marital_status"
    t.integer "years_married"
    t.integer "num_children_born"
    t.integer "num_children_alive"
    t.string "pob"
    t.string "pob_father"
    t.string "pob_mother"
    t.integer "year_immigrated"
    t.string "naturalized_alien"
    t.integer "years_in_us"
    t.string "occupation", default: "None"
    t.integer "unemployed_months"
    t.boolean "attended_school_old"
    t.boolean "can_read"
    t.boolean "can_write"
    t.boolean "can_speak_english"
    t.string "owned_or_rented"
    t.string "mortgage"
    t.string "farm_or_house"
    t.string "language_spoken", default: "English"
    t.text "notes"
    t.boolean "provisional", default: false
    t.boolean "foreign_born", default: false
    t.boolean "taker_error", default: false
    t.integer "attended_school"
    t.string "industry"
    t.integer "farm_schedule"
    t.string "name_prefix"
    t.string "name_suffix"
    t.text "searchable_name"
    t.string "apartment_number"
    t.integer "age_months"
    t.bigint "locality_id"
    t.uuid "histid"
    t.integer "enum_dist"
    t.integer "ward"
    t.index ["building_id"], name: "index_census_1900_records_on_building_id"
    t.index ["data"], name: "index_census_1900_records_on_data", using: :gin
    t.index ["locality_id"], name: "index_census_1900_records_on_locality_id"
    t.index ["person_id"], name: "index_census_1900_records_on_person_id"
    t.index ["searchable_name"], name: "census_1900_records_name_trgm", opclass: :gist_trgm_ops, using: :gist
  end

  create_table "census_1910_records", id: :serial, force: :cascade do |t|
    t.jsonb "data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "building_id"
    t.integer "created_by_id"
    t.integer "reviewed_by_id"
    t.datetime "reviewed_at", precision: nil
    t.integer "person_id"
    t.integer "page_number"
    t.string "page_side", limit: 1
    t.integer "line_number"
    t.string "county"
    t.string "city"
    t.string "state"
    t.string "ward_str"
    t.string "enum_dist_str"
    t.string "street_prefix"
    t.string "street_name"
    t.string "street_suffix"
    t.string "street_house_number"
    t.string "dwelling_number"
    t.string "family_id"
    t.string "last_name"
    t.string "first_name"
    t.string "middle_name"
    t.string "relation_to_head"
    t.string "sex"
    t.string "race"
    t.integer "age"
    t.string "marital_status"
    t.integer "years_married"
    t.integer "num_children_born"
    t.integer "num_children_alive"
    t.string "pob"
    t.string "pob_father"
    t.string "pob_mother"
    t.integer "year_immigrated"
    t.string "naturalized_alien"
    t.string "occupation", default: "None"
    t.string "industry"
    t.string "employment"
    t.boolean "unemployed"
    t.boolean "attended_school"
    t.boolean "can_read"
    t.boolean "can_write"
    t.boolean "can_speak_english"
    t.string "owned_or_rented"
    t.string "mortgage"
    t.string "farm_or_house"
    t.string "num_farm_sched"
    t.string "language_spoken", default: "English"
    t.string "unemployed_weeks_1909"
    t.boolean "civil_war_vet_old"
    t.boolean "blind", default: false
    t.boolean "deaf_dumb", default: false
    t.text "notes"
    t.string "civil_war_vet", limit: 2
    t.boolean "provisional", default: false
    t.boolean "foreign_born", default: false
    t.boolean "taker_error", default: false
    t.string "name_prefix"
    t.string "name_suffix"
    t.text "searchable_name"
    t.string "apartment_number"
    t.integer "age_months"
    t.string "mother_tongue"
    t.string "mother_tongue_father"
    t.string "mother_tongue_mother"
    t.bigint "locality_id"
    t.uuid "histid"
    t.integer "enum_dist"
    t.integer "ward"
    t.index ["building_id"], name: "index_census_1910_records_on_building_id"
    t.index ["created_by_id"], name: "index_census_1910_records_on_created_by_id"
    t.index ["data"], name: "index_census_1910_records_on_data", using: :gin
    t.index ["locality_id"], name: "index_census_1910_records_on_locality_id"
    t.index ["person_id"], name: "index_census_1910_records_on_person_id", unique: true
    t.index ["reviewed_by_id"], name: "index_census_1910_records_on_reviewed_by_id"
    t.index ["searchable_name"], name: "census_1910_records_name_trgm", opclass: :gist_trgm_ops, using: :gist
  end

  create_table "census_1920_records", id: :serial, force: :cascade do |t|
    t.integer "created_by_id"
    t.integer "reviewed_by_id"
    t.datetime "reviewed_at", precision: nil
    t.integer "page_number"
    t.string "page_side", limit: 1
    t.integer "line_number"
    t.string "county"
    t.string "city"
    t.string "state"
    t.string "ward_str"
    t.string "enum_dist_str"
    t.string "street_prefix"
    t.string "street_name"
    t.string "street_suffix"
    t.string "street_house_number"
    t.string "dwelling_number"
    t.string "family_id"
    t.string "last_name"
    t.string "first_name"
    t.string "middle_name"
    t.string "relation_to_head"
    t.string "sex"
    t.string "race"
    t.integer "age"
    t.string "marital_status"
    t.integer "year_immigrated"
    t.string "naturalized_alien"
    t.string "pob"
    t.string "mother_tongue"
    t.string "pob_father"
    t.string "mother_tongue_father"
    t.string "pob_mother"
    t.string "mother_tongue_mother"
    t.boolean "can_speak_english"
    t.string "occupation", default: "None"
    t.string "industry"
    t.string "employment"
    t.boolean "attended_school"
    t.boolean "can_read"
    t.boolean "can_write"
    t.string "owned_or_rented"
    t.string "mortgage"
    t.string "farm_or_house"
    t.text "notes"
    t.boolean "provisional", default: false
    t.boolean "foreign_born", default: false
    t.boolean "taker_error", default: false
    t.integer "person_id"
    t.integer "building_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "name_prefix"
    t.string "name_suffix"
    t.integer "year_naturalized"
    t.integer "farm_schedule"
    t.text "searchable_name"
    t.string "apartment_number"
    t.integer "age_months"
    t.string "employment_code"
    t.bigint "locality_id"
    t.uuid "histid"
    t.integer "enum_dist"
    t.integer "ward"
    t.index ["building_id"], name: "index_census_1920_records_on_building_id"
    t.index ["locality_id"], name: "index_census_1920_records_on_locality_id"
    t.index ["person_id"], name: "index_census_1920_records_on_person_id"
    t.index ["searchable_name"], name: "census_1920_records_name_trgm", opclass: :gist_trgm_ops, using: :gist
  end

  create_table "census_1930_records", id: :serial, force: :cascade do |t|
    t.integer "building_id"
    t.integer "person_id"
    t.integer "created_by_id"
    t.integer "reviewed_by_id"
    t.datetime "reviewed_at", precision: nil
    t.integer "page_number"
    t.string "page_side", limit: 1
    t.integer "line_number"
    t.string "county"
    t.string "city"
    t.string "state"
    t.string "ward_str"
    t.string "enum_dist_str"
    t.string "street_prefix"
    t.string "street_name"
    t.string "street_suffix"
    t.string "street_house_number"
    t.string "dwelling_number"
    t.string "family_id"
    t.string "last_name"
    t.string "first_name"
    t.string "middle_name"
    t.string "relation_to_head"
    t.string "owned_or_rented"
    t.decimal "home_value"
    t.boolean "has_radio"
    t.boolean "lives_on_farm"
    t.string "sex"
    t.string "race"
    t.integer "age"
    t.string "marital_status"
    t.integer "age_married"
    t.boolean "attended_school"
    t.boolean "can_read_write"
    t.string "pob"
    t.string "pob_father"
    t.string "pob_mother"
    t.string "pob_code"
    t.string "pob_father_code"
    t.string "pob_mother_code"
    t.string "mother_tongue"
    t.integer "year_immigrated"
    t.string "naturalized_alien"
    t.boolean "can_speak_english"
    t.string "occupation", default: "None"
    t.string "industry"
    t.string "occupation_code"
    t.string "worker_class"
    t.boolean "worked_yesterday"
    t.string "unemployment_line"
    t.boolean "veteran"
    t.string "war_fought"
    t.string "farm_schedule"
    t.text "notes"
    t.boolean "provisional", default: false
    t.boolean "foreign_born", default: false
    t.boolean "taker_error", default: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "name_prefix"
    t.string "name_suffix"
    t.text "searchable_name"
    t.integer "has_radio_int"
    t.integer "lives_on_farm_int"
    t.integer "attended_school_int"
    t.integer "can_read_write_int"
    t.integer "can_speak_english_int"
    t.integer "worked_yesterday_int"
    t.integer "veteran_int"
    t.integer "foreign_born_int"
    t.integer "homemaker_int"
    t.integer "age_months"
    t.string "apartment_number"
    t.boolean "homemaker"
    t.bigint "industry1930_code_id"
    t.bigint "occupation1930_code_id"
    t.bigint "locality_id"
    t.uuid "histid"
    t.integer "enum_dist"
    t.integer "ward"
    t.index ["building_id"], name: "index_census_1930_records_on_building_id"
    t.index ["created_by_id"], name: "index_census_1930_records_on_created_by_id"
    t.index ["industry1930_code_id"], name: "index_census_1930_records_on_industry1930_code_id"
    t.index ["locality_id"], name: "index_census_1930_records_on_locality_id"
    t.index ["occupation1930_code_id"], name: "index_census_1930_records_on_occupation1930_code_id"
    t.index ["person_id"], name: "index_census_1930_records_on_person_id"
    t.index ["reviewed_by_id"], name: "index_census_1930_records_on_reviewed_by_id"
    t.index ["searchable_name"], name: "census_1930_records_name_trgm", opclass: :gist_trgm_ops, using: :gist
  end

  create_table "census_1940_records", force: :cascade do |t|
    t.bigint "building_id"
    t.bigint "person_id"
    t.bigint "created_by_id"
    t.bigint "reviewed_by_id"
    t.datetime "reviewed_at", precision: nil
    t.integer "page_number"
    t.string "page_side", limit: 1
    t.integer "line_number"
    t.string "county"
    t.string "city"
    t.string "state"
    t.string "ward_str"
    t.string "enum_dist_str"
    t.string "apartment_number"
    t.string "street_prefix"
    t.string "street_name"
    t.string "street_suffix"
    t.string "street_house_number"
    t.string "dwelling_number"
    t.string "family_id"
    t.string "last_name"
    t.string "first_name"
    t.string "middle_name"
    t.string "name_prefix"
    t.string "name_suffix"
    t.text "searchable_name"
    t.string "owned_or_rented"
    t.decimal "home_value"
    t.boolean "lives_on_farm"
    t.string "relation_to_head"
    t.string "sex"
    t.string "race"
    t.integer "age"
    t.integer "age_months"
    t.string "marital_status"
    t.boolean "attended_school"
    t.string "grade_completed"
    t.string "pob"
    t.string "naturalized_alien"
    t.string "residence_1935_town"
    t.string "residence_1935_county"
    t.string "residence_1935_state"
    t.boolean "residence_1935_farm"
    t.boolean "private_work"
    t.boolean "public_work"
    t.boolean "seeking_work"
    t.boolean "had_job"
    t.string "no_work_reason"
    t.integer "private_hours_worked"
    t.integer "unemployed_weeks"
    t.string "occupation", default: "None"
    t.string "industry"
    t.string "worker_class"
    t.string "occupation_code"
    t.integer "full_time_weeks"
    t.integer "income"
    t.boolean "had_unearned_income"
    t.string "farm_schedule"
    t.string "pob_father"
    t.string "pob_mother"
    t.string "mother_tongue"
    t.boolean "veteran"
    t.boolean "veteran_dead"
    t.string "war_fought"
    t.boolean "soc_sec"
    t.boolean "deductions"
    t.string "deduction_rate"
    t.string "usual_occupation"
    t.string "usual_industry"
    t.string "usual_worker_class"
    t.string "usual_occupation_code"
    t.string "usual_industry_code"
    t.string "usual_worker_class_code"
    t.boolean "multi_marriage"
    t.integer "first_marriage_age"
    t.integer "children_born"
    t.text "notes"
    t.boolean "provisional", default: false
    t.boolean "foreign_born", default: false
    t.boolean "taker_error", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "worker_class_code"
    t.string "industry_code"
    t.bigint "locality_id"
    t.uuid "histid"
    t.integer "enum_dist"
    t.integer "ward"
    t.boolean "income_plus"
    t.index ["building_id"], name: "index_census_1940_records_on_building_id"
    t.index ["created_by_id"], name: "index_census_1940_records_on_created_by_id"
    t.index ["locality_id"], name: "index_census_1940_records_on_locality_id"
    t.index ["person_id"], name: "index_census_1940_records_on_person_id"
    t.index ["reviewed_by_id"], name: "index_census_1940_records_on_reviewed_by_id"
  end

  create_table "client_applications", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.string "support_url"
    t.string "callback_url"
    t.string "key", limit: 20
    t.string "secret", limit: 40
    t.integer "user_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["key"], name: "index_client_applications_on_key", unique: true
  end

  create_table "cms_page_widgets", force: :cascade do |t|
    t.bigint "cms_page_id"
    t.string "type"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cms_page_id"], name: "index_cms_page_widgets_on_cms_page_id"
  end

  create_table "cms_pages", force: :cascade do |t|
    t.string "type", default: "Cms::Page"
    t.string "url_path"
    t.string "controller"
    t.string "action"
    t.boolean "published", default: true
    t.boolean "visible", default: false
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["controller", "action"], name: "index_cms_pages_on_controller_and_action"
    t.index ["url_path"], name: "index_cms_pages_on_url_path"
  end

  create_table "construction_materials", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "color"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "contacts", force: :cascade do |t|
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "document_categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "documents", force: :cascade do |t|
    t.bigint "document_category_id"
    t.string "file"
    t.string "name"
    t.text "description"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["document_category_id"], name: "index_documents_on_document_category_id"
  end

  create_table "flags", force: :cascade do |t|
    t.string "flaggable_type"
    t.bigint "flaggable_id"
    t.bigint "user_id"
    t.string "reason"
    t.text "message"
    t.text "comment"
    t.bigint "resolved_by_id"
    t.datetime "resolved_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flaggable_type", "flaggable_id"], name: "index_flags_on_flaggable_type_and_flaggable_id"
    t.index ["resolved_by_id"], name: "index_flags_on_resolved_by_id"
    t.index ["user_id"], name: "index_flags_on_user_id"
  end

  create_table "imports", id: :serial, force: :cascade do |t|
    t.string "path"
    t.string "name"
    t.string "layer_title"
    t.string "map_title_suffix"
    t.string "map_description"
    t.string "map_publisher"
    t.string "map_author"
    t.string "state"
    t.integer "layer_id"
    t.integer "uploader_user_id"
    t.integer "user_id"
    t.integer "file_count"
    t.integer "imported_count"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "industry1930_codes", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ipums_records", primary_key: "histid", id: :uuid, default: nil, force: :cascade do |t|
    t.integer "serial"
    t.integer "year"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["histid"], name: "index_ipums_records_on_histid"
  end

  create_table "localities", force: :cascade do |t|
    t.string "name"
    t.decimal "latitude"
    t.decimal "longitude"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "year_street_renumber"
  end

  create_table "localities_map_overlays", id: false, force: :cascade do |t|
    t.bigint "locality_id", null: false
    t.bigint "map_overlay_id", null: false
  end

  create_table "map_overlays", force: :cascade do |t|
    t.string "name"
    t.integer "year_depicted"
    t.string "url"
    t.boolean "active"
    t.integer "position"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "locality_id"
    t.index ["locality_id"], name: "index_map_overlays_on_locality_id"
  end

  create_table "occupation1930_codes", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "people", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "last_name"
    t.string "first_name"
    t.string "middle_name"
    t.string "sex", limit: 12
    t.string "race", limit: 12
    t.string "name_prefix"
    t.string "name_suffix"
    t.text "searchable_name"
    t.integer "birth_year"
    t.boolean "is_birth_year_estimated", default: true
    t.string "pob"
    t.boolean "is_pob_estimated", default: true
    t.text "notes"
    t.index ["searchable_name"], name: "people_name_trgm", opclass: :gist_trgm_ops, using: :gist
  end

  create_table "people_photographs", id: false, force: :cascade do |t|
    t.bigint "photograph_id", null: false
    t.bigint "person_id", null: false
  end

  create_table "permissions", id: :serial, force: :cascade do |t|
    t.integer "role_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.bigint "searchable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id"
  end

  create_table "photographs", force: :cascade do |t|
    t.bigint "created_by_id"
    t.bigint "building_id"
    t.text "description"
    t.string "creator"
    t.string "date_text"
    t.date "date_start"
    t.date "date_end"
    t.string "location"
    t.string "identifier"
    t.text "notes"
    t.decimal "latitude"
    t.decimal "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "reviewed_by_id"
    t.datetime "reviewed_at", precision: nil
    t.integer "date_type", default: 0
    t.text "caption"
    t.index ["building_id"], name: "index_photographs_on_building_id"
    t.index ["created_by_id"], name: "index_photographs_on_created_by_id"
    t.index ["reviewed_by_id"], name: "index_photographs_on_reviewed_by_id"
  end

  create_table "profession_groups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "profession_subgroups", force: :cascade do |t|
    t.string "name"
    t.bigint "profession_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profession_group_id"], name: "index_profession_subgroups_on_profession_group_id"
  end

  create_table "professions", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.bigint "profession_group_id"
    t.bigint "profession_subgroup_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profession_group_id"], name: "index_professions_on_profession_group_id"
    t.index ["profession_subgroup_id"], name: "index_professions_on_profession_subgroup_id"
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "updated_by"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "search_params", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "model"
    t.jsonb "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_search_params_on_user_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string "key"
    t.string "name"
    t.string "hint"
    t.string "input_type"
    t.string "group"
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "settings_group_id"
    t.index ["settings_group_id"], name: "index_settings_on_settings_group_id"
  end

  create_table "settings_groups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "street_conversions", force: :cascade do |t|
    t.string "from_prefix"
    t.string "to_prefix"
    t.string "from_name"
    t.string "to_name"
    t.string "from_suffix"
    t.string "to_suffix"
    t.string "from_city"
    t.string "to_city"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "from_house_number"
    t.string "to_house_number"
    t.integer "year"
  end

  create_table "terms", force: :cascade do |t|
    t.bigint "vocabulary_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "ipums"
    t.index ["name"], name: "index_terms_on_name"
    t.index ["vocabulary_id"], name: "index_terms_on_vocabulary_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "login"
    t.string "email"
    t.string "encrypted_password", limit: 128, default: "", null: false
    t.string "password_salt", default: "", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "remember_token"
    t.datetime "remember_token_expires_at", precision: nil
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.string "reset_password_token"
    t.boolean "enabled", default: true
    t.integer "updated_by"
    t.text "description", default: ""
    t.datetime "confirmation_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "reset_password_sent_at", precision: nil
    t.string "provider"
    t.string "uid"
    t.string "invitation_token"
    t.datetime "invitation_created_at", precision: nil
    t.datetime "invitation_sent_at", precision: nil
    t.datetime "invitation_accepted_at", precision: nil
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.integer "roles_mask"
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at", precision: nil
    t.text "object_changes"
    t.string "comment"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "vocabularies", force: :cascade do |t|
    t.string "name"
    t.string "machine_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["machine_name"], name: "index_vocabularies_on_machine_name"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "buildings"
  add_foreign_key "annotations", "buildings"
  add_foreign_key "annotations", "map_overlays"
  add_foreign_key "buildings", "localities"
  add_foreign_key "buildings", "users", column: "created_by_id"
  add_foreign_key "buildings", "users", column: "reviewed_by_id"
  add_foreign_key "bulk_updated_records", "bulk_updates"
  add_foreign_key "bulk_updates", "users"
  add_foreign_key "census1950_records", "buildings"
  add_foreign_key "census1950_records", "localities"
  add_foreign_key "census1950_records", "people"
  add_foreign_key "census1950_records", "users", column: "created_by_id"
  add_foreign_key "census1950_records", "users", column: "reviewed_by_id"
  add_foreign_key "census_1880_records", "buildings"
  add_foreign_key "census_1880_records", "localities"
  add_foreign_key "census_1880_records", "people"
  add_foreign_key "census_1880_records", "users", column: "created_by_id"
  add_foreign_key "census_1880_records", "users", column: "reviewed_by_id"
  add_foreign_key "census_1900_records", "buildings"
  add_foreign_key "census_1900_records", "localities"
  add_foreign_key "census_1900_records", "people"
  add_foreign_key "census_1900_records", "users", column: "created_by_id"
  add_foreign_key "census_1900_records", "users", column: "reviewed_by_id"
  add_foreign_key "census_1910_records", "buildings"
  add_foreign_key "census_1910_records", "localities"
  add_foreign_key "census_1910_records", "people"
  add_foreign_key "census_1910_records", "users", column: "created_by_id"
  add_foreign_key "census_1910_records", "users", column: "reviewed_by_id"
  add_foreign_key "census_1920_records", "buildings"
  add_foreign_key "census_1920_records", "localities"
  add_foreign_key "census_1920_records", "people"
  add_foreign_key "census_1920_records", "users", column: "created_by_id"
  add_foreign_key "census_1920_records", "users", column: "reviewed_by_id"
  add_foreign_key "census_1930_records", "buildings"
  add_foreign_key "census_1930_records", "industry1930_codes"
  add_foreign_key "census_1930_records", "localities"
  add_foreign_key "census_1930_records", "occupation1930_codes"
  add_foreign_key "census_1930_records", "people"
  add_foreign_key "census_1930_records", "users", column: "created_by_id"
  add_foreign_key "census_1930_records", "users", column: "reviewed_by_id"
  add_foreign_key "census_1940_records", "buildings"
  add_foreign_key "census_1940_records", "localities"
  add_foreign_key "census_1940_records", "people"
  add_foreign_key "census_1940_records", "users", column: "created_by_id"
  add_foreign_key "census_1940_records", "users", column: "reviewed_by_id"
  add_foreign_key "cms_page_widgets", "cms_pages"
  add_foreign_key "documents", "document_categories"
  add_foreign_key "flags", "users"
  add_foreign_key "flags", "users", column: "resolved_by_id"
  add_foreign_key "map_overlays", "localities"
  add_foreign_key "photographs", "buildings"
  add_foreign_key "photographs", "users", column: "created_by_id"
  add_foreign_key "photographs", "users", column: "reviewed_by_id"
  add_foreign_key "profession_subgroups", "profession_groups"
  add_foreign_key "professions", "profession_groups"
  add_foreign_key "professions", "profession_subgroups"
  add_foreign_key "search_params", "users"
  add_foreign_key "settings", "settings_groups"
  add_foreign_key "terms", "vocabularies"
end
