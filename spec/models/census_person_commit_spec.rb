# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Census person links at transaction boundaries', type: :model do
  # These examples must cross a real commit, not a savepoint inside a fixture transaction.
  self.use_transactional_tests = false

  before do
    @user = create(:active_user)
    @person = create(:person)
    @record = create(:census1910_record)
  end

  after do
    # Remove only records owned by this example; preserve the suite's seed data.
    @record.destroy!
    AuditLog.where(loggable: @person).delete_all
    @person.names.delete_all
    @person.localities.clear
    @person.delete
    @record.locality.destroy!
    @user.destroy!
    Current.reset
  end

  it 'applies names, locality, and attributed audit history only after commit' do
    PaperTrail.request(whodunnit: @user.id.to_s) do
      Person.transaction do
        @record.update!(person: @person)
        expect(@person.audit_logs.where('message LIKE ?', 'Connected to%')).to be_empty
        expect(@person.localities).not_to include(@record.locality)
      end
    end

    logs = @person.audit_logs.where('message LIKE ?', 'Connected to 1910%')
    expect(logs.count).to eq(1)
    expect(logs.first.user_id).to eq(@user.id)
    expect(@person.reload.localities).to include(@record.locality)
    expect(@person.names.pluck(:first_name)).to include(@record.first_name)

    @record.update!(notes: 'Unrelated correction')
    expect(logs.count).to eq(1)
  end

  it 'leaves no link, name, locality, or audit side effects on rollback' do
    original_names = @person.names.pluck(:id)
    original_logs = @person.audit_logs.pluck(:id)
    Person.transaction do
      @record.update!(person: @person)
      raise ActiveRecord::Rollback
    end

    expect(@record.reload.person_id).to be_nil
    expect(@person.names.pluck(:id)).to eq(original_names)
    expect(@person.audit_logs.pluck(:id)).to eq(original_logs)
    expect(@person.localities).not_to include(@record.locality)
  end
end
