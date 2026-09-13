# frozen_string_literal: true

require 'rails_helper'
require 'stringio'

RSpec.describe InstallationBootstrap do
  let(:output) { StringIO.new }

  it 'initializes reference data and creates a confirmed administrator, preserving them on rerun' do
    User.destroy_all
    service = described_class.new(input: StringIO.new("bootstrap_admin\nbootstrap@example.org\n"), output:)
    service.run
    admin = User.find_by!(email: 'bootstrap@example.org')
    expect(admin).to be_confirmed
    expect(admin.role?('Administrator')).to be true
    expect(Occupation1930Code.count).to be_positive
    term = Vocabulary.find_by!(machine_name: 'language').terms.first!
    term.update!(ipums: 123)
    occupation = Occupation1930Code.first!
    occupation.update!(name: 'Locally edited description')
    counts = [User.count, Term.count, Occupation1930Code.count]
    password = admin.encrypted_password

    described_class.new(input: StringIO.new, output:).run

    expect([User.count, Term.count, Occupation1930Code.count]).to eq(counts)
    expect(term.reload.ipums).to eq(123)
    expect(occupation.reload.name).to eq('Locally edited description')
    expect(admin.reload.encrypted_password).to eq(password)
  end

  it 'fails clearly when input ends and can resume without duplicating reference data' do
    User.destroy_all
    expect { described_class.new(input: StringIO.new, output:).run }.to raise_error(ArgumentError, /interactive terminal/)
    counts = [Term.count, Occupation1930Code.count]
    described_class.new(input: StringIO.new("resumed_admin\nresumed@example.org\n"), output:).run
    expect([Term.count, Occupation1930Code.count]).to eq(counts)
    expect(User.find_by!(email: 'resumed@example.org').role?('Administrator')).to be true
  end
end
