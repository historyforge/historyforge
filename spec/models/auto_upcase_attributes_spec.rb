# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AutoStripAttributes do
  subject { Census1930Record.new }
  it 'works' do
    subject.occupation_code = 'vx'
    subject.validate
    expect(subject.occupation_code).to eq('VX')
  end
end
