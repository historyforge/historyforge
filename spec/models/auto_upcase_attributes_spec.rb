# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AutoStripAttributes do
  let(:record) { Census1930Record.new }

  it 'validates occupation_code' do
    record.occupation_code = 'vx'
    record.validate
    expect(record.occupation_code).to eq('VX')
  end
end
