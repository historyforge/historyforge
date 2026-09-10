# frozen_string_literal: true

require 'rails_helper'
require 'tempfile'
require 'vips'

RSpec.describe 'CMS direct uploads', type: :feature do
  scenario 'uploads a picture directly and attaches it when the page is saved' do
    sign_in create(:administrator)
    cms_page = Cms::Page.create!(title: 'Upload test', url_path: '/upload-test')
    picture = cms_page.widgets.create!(type: 'Cms::Picture', name: 'picture', human_name: 'Picture')

    Tempfile.create(['cms-picture', '.jpg']) do |file|
      bytes = Vips::Image.black(20, 10).jpegsave_buffer
      file.binmode
      file.write(bytes)
      file.flush

      visit edit_cms_page_path(cms_page)
      within('.nav-tabs') do
        click_link 'Media'
        click_link 'Picture'
      end
      page.execute_script("document.addEventListener('direct-upload:end', () => { sessionStorage.setItem('cms-upload-finished', 'true') })")
      attach_file 'File to upload', file.path
      find('#cms-page-form input[type="submit"]', match: :first).click

      expect(page).to have_content('Successfully updated page')
      expect(page.evaluate_script("sessionStorage.getItem('cms-upload-finished')")).to eq('true')
      expect(picture.reload.file).to be_attached
      expect(picture.file.download).to eq(bytes)
      picture.file.purge
    end
  end
end
