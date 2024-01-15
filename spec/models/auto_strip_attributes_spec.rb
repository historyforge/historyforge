# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AutoStripAttributes do
  let(:building) { Building.new }

  it 'removes leading whitespace' do
    building.name = '  foo  '
    building.validate
    expect(building.name).to eq('foo')
  end

  it 'converts empty strings to null' do
    building.stories = ''
    building.validate
    expect(building.stories).to be_nil
  end
end
