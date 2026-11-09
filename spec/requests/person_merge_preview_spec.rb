# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Person merge preview', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:source) { create(:person) }
  let(:target) { create(:person) }
  let(:preview_path) { new_person_merge_path(target, merge_id: source.id) }

  it 'shows linked census records on both sides even when their detail pages are restricted' do
    editor = create(:active_user)
    editor.add_role Role.find_by(name: 'person record editor')
    sign_in editor

    unreviewed = create(:census1910_record, person: source)
    restricted = create(:census1930_record)
    restricted.update_columns(person_id: target.id, reviewed_at: Time.current)
    allow(Setting).to receive(:can_view_public?).and_call_original
    allow(Setting).to receive(:can_view_public?).with(1910).and_return(true)
    allow(Setting).to receive(:can_view_public?).with(1930).and_return(false)
    allow(Setting).to receive(:can_view_private?).and_call_original
    allow(Setting).to receive(:can_view_private?).with(1930).and_return(false)

    get preview_path

    expect(response).to have_http_status(:ok)
    page = Nokogiri::HTML(response.body)
    expect(page.css('.card-body tbody a').map { |link| link['href'] })
      .to eq([polymorphic_path(unreviewed), polymorphic_path(restricted)])

    [unreviewed, restricted].each do |record|
      get polymorphic_path(record)
      expect(response).to redirect_to(root_path)
    end
  end

  it 'denies the preview to signed-in readers without merge permission' do
    sign_in create(:active_user)

    get preview_path

    expect(response).to redirect_to(root_path)
  end
end
