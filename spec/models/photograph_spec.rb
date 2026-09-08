# frozen_string_literal: true

require 'rails_helper'
require 'vips'

RSpec.describe Photograph, type: :model do
  let(:photo) { described_class.new(caption: 'Canal warehouse', created_by: create(:active_user)) }
  let(:png) { Vips::Image.black(20, 10).pngsave_buffer }

  after do
    photo.file.purge if photo.file.attached?
  end

  it 'requires a file' do
    expect(photo).not_to be_valid
    expect(photo.errors[:file]).to be_present
  end

  it 'rejects unsupported content' do
    photo.file.attach(io: StringIO.new('not an image'), filename: 'notes.txt', content_type: 'text/plain')
    expect(photo).not_to be_valid
    expect(photo.errors[:file]).to be_present
  end

  it 'stores the original and produces a downloadable thumbnail' do
    photo.file.attach(io: StringIO.new(png), filename: 'warehouse.png', content_type: 'image/png')
    photo.save!
    photo.reload

    expect(photo.file.download).to eq(png)
    thumbnail = photo.file.variant(resize_to_limit: [5, 5]).processed
    image = Vips::Image.new_from_buffer(thumbnail.download, '')
    expect(image.width).to eq(5)
    expect(image.height).to be_between(2, 3)
  end
end
