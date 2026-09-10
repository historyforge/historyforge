# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VolunteerApplication do
  def application(**attributes)
    described_class.new({ name: 'Volunteer', email: 'person@example.org', how_heard: 'Friend' }.merge(attributes))
  end

  it 'allows optional interests and experience to be unanswered' do
    expect(application(experience: '')).to be_valid
  end

  it 'requires the original required fields and a valid email address' do
    %i[name email how_heard].each { |field| expect(application(field => '')).not_to be_valid }
    expect(application(email: 'invalid')).not_to be_valid
  end

  it 'allows an optional experience explanation and rejects unknown values' do
    expect(application(experience: 'yes')).to be_valid
    expect(application(experience: 'yes', experience_details: 'Scanning')).to be_valid
    expect(application(experience: 'unknown')).not_to be_valid
  end

  it 'preserves submitted contact details when a linked account changes' do
    record = application
    record.user = create(:active_user)
    record.save!
    record.user.update!(full_name: 'Updated', email: 'updated@example.org')
    expect(record.reload.name).to eq('Volunteer')
    expect(record.email).to eq('person@example.org')
  end

  it 'preserves locality names when localities change or are deleted' do
    locality = create(:locality)
    record = application(locality_names: [locality.name], opportunity_interests: ['maps'])
    record.save!
    old_name = locality.name
    locality.update!(name: 'Renamed locality')
    locality.destroy!
    expect(record.reload.locality_names).to eq([old_name])
    expect(record.opportunity_labels).to eq(['Working with historic maps'])
  end

  it 'rejects unknown opportunity codes' do
    expect(application(opportunity_interests: ['made_up'])).not_to be_valid
  end
end
