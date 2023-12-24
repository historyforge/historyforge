# frozen_string_literal: true

require 'rails_helper'

RSpec.describe People::Merge do
  let(:source) { create(:person, description: 'source text') }
  let(:target) { create(:person, description: 'target text') }
  let!(:source_record) { create(:census1910_record, person: source) }
  let!(:target_record) { create(:census1920_record, person: target) }
  subject { described_class.new(source, target) }
  before do
    PaperTrail.request.whodunnit = create(:user)
  end
  it 'merges successfully' do
    source_name = source.names.first.name
    subject.perform
    expect(source.destroyed?).to be_truthy
    expect(target.names.map(&:name)).to include(source_name)
    expect(target.census1910_records).to include(source_record)
    expect(target.census1920_records).to include(target_record)
    expect(target.description).to include('target text')
    expect(target.description).to include('source text')
    expect(target.audit_logs.count).to eq(2)
  end
end
