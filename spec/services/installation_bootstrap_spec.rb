# frozen_string_literal: true

require 'rails_helper'
require 'rake'
require 'stringio'

RSpec.describe InstallationBootstrap do
  it 'refuses an existing database before loading schema or seeds' do
    expect(Rake::Task).not_to receive(:[])
    expect { described_class.new.run }.to raise_error(/empty database/)
  end

  it 'loads schema, seeds, reference data, and administrator in that order for an empty database' do
    allow(ApplicationRecord.connection).to receive(:tables).and_return(%w[schema_migrations ar_internal_metadata])
    schema = double('schema task')
    seeds = double('seed task')
    codes = instance_double(LoadOccupationCodes)
    admin = instance_double(CreateAdministrator)
    allow(Rake::Task).to receive(:[]).with('db:schema:load').and_return(schema)
    allow(Rake::Task).to receive(:[]).with('db:seed').and_return(seeds)
    allow(LoadOccupationCodes).to receive(:new).and_return(codes)
    allow(CreateAdministrator).to receive(:new).and_return(admin)
    expect(schema).to receive(:invoke).ordered
    expect(seeds).to receive(:invoke).ordered
    expect(codes).to receive(:run).ordered
    expect(admin).to receive(:run).ordered
    described_class.new(output: StringIO.new).run
  end
end

RSpec.describe LoadOccupationCodes do
  it 'adds missing codes while preserving existing IDs and locally edited names on retries' do
    Occupation1930Code.delete_all
    existing = Occupation1930Code.create!(code: '80 1V', name: 'Local description')
    described_class.new.run
    count = Occupation1930Code.count
    expect(count).to be > 1
    expect(existing.reload.name).to eq('Local description')
    expect(Occupation1930Code.find_by!(code: '80 1V').id).to eq(existing.id)
    described_class.new.run
    expect(Occupation1930Code.count).to eq(count)
  end
end

RSpec.describe CreateAdministrator do
  it 'creates a confirmed administrator with a working generated password' do
    output = StringIO.new
    described_class.new(input: StringIO.new("bootstrap_admin\nbootstrap@example.org\n"), output:).run
    admin = User.find_by!(email: 'bootstrap@example.org')
    expect(admin).to be_confirmed
    expect(admin.role?('Administrator')).to be true
    expect(admin.valid_password?(output.string[/Password: (.+)/, 1])).to be true
  end

  it 'does not create an account when input is interrupted' do
    expect { described_class.new(input: StringIO.new, output: StringIO.new).run }.to raise_error(ArgumentError, /interactive terminal/)
  end
end
