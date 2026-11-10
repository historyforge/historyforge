# frozen_string_literal: true

require 'rails_helper'
require 'rake'
require 'stringio'
require 'tempfile'
require 'parallel'

RSpec.describe 'import:census_parallel' do
  let!(:user) { create(:administrator) }
  let!(:existing) do
    create(:census1920_record, city: 'Ithaca', ward: '2', enum_dist: '3', page_number: 7,
           page_side: 'A', line_number: 1, first_name: 'Original')
  end

  before do
    # Keep the real task and row processing inside the example's database transaction.
    allow(Etc).to receive(:nprocessors).and_return(0)
  end

  it 'reports a dry run without saving census records, people, or address data' do
    expect do
      report = import_csv(dry_run: true)
      expect(report).to include('mode' => 'dry_run', 'total' => 3, 'successful' => 2, 'failed' => 1)
      expect(report.fetch('errors').map { |row| row.fetch('index') }).to eq([3])
    end.not_to change { [Census1920Record.count, Person.count, Locality.count, Building.count, Address.count] }

    expect(existing.reload.first_name).to eq('Original')
  end

  it 'imports valid rows, rolls back related data for rejected rows, and updates on rerun' do
    report = import_csv(dry_run: false)

    expect(report).to include('mode' => 'import', 'total' => 3, 'successful' => 2, 'failed' => 1)
    expect(report.fetch('errors').map { |row| row.fetch('index') }).to eq([3])
    expect(existing.reload.first_name).to eq('Updated')
    imported = Census1920Record.find_by!(first_name: 'New')
    expect(imported).to be_reviewed
    person_id = imported.person_id
    expect(person_id).to be_present
    expect(imported.building.addresses.first.name).to eq('Foundry')
    expect(Locality.exists?(name: 'Rejected locality')).to be(false)
    expect(Address.exists?(name: 'Rejected Street')).to be(false)

    expect do
      repeat = import_csv(dry_run: false, new_name: 'Revised')
      expect(repeat).to include('successful' => 2, 'failed' => 1)
    end.not_to change { [Census1920Record.count, Person.count, Locality.count, Building.count, Address.count] }
    expect(imported.reload).to have_attributes(first_name: 'Revised', person_id:)
  end

  def import_csv(dry_run:, new_name: 'New')
    output = StringIO.new
    original_stdout = $stdout
    original_logger = ActiveRecord::Base.logger
    original_skip_validation = Thread.current[:skip_vocabulary_validation]
    Tempfile.create(['historyforge-census', '.csv']) do |csv|
      csv.write(<<~CSV)
        City,Ward,Enum Dist,Sheet,Side,Line,First Name,Last Name,Family No.,Dwelling No.,Occupation,County,State,Relation to Head,Sex,Race,Locality,House No.,Street Name
        Ithaca,2,3,7,A,1,Updated,Canal,1,1,Carpenter,Tompkins,New York,Head,F,W,Import locality,10,Foundry
        Ithaca,2,3,7,A,2,#{new_name},Railway,2,2,Carpenter,Tompkins,New York,Head,F,W,Import locality,12,Foundry
        Ithaca,2,3,7,A,3,,Invalid,3,3,Carpenter,Tompkins,New York,Head,F,W,Rejected locality,14,Rejected Street
      CSV
      csv.flush

      $stdout = output
      Rake.with_application do
        Rake::Task.define_task(:environment)
        load Rails.root.join('lib/tasks/import.rake')
        Rake::Task['import:census_parallel'].invoke('1920', csv.path, dry_run.to_s, 'true')
      end
    end
    JSON.parse(output.string.lines.last)
  ensure
    $stdout = original_stdout
    ActiveRecord::Base.logger = original_logger
    Thread.current[:skip_vocabulary_validation] = original_skip_validation
  end
end
