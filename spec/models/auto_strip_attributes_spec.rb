# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AutoStripAttributes do
  subject { Building.new }
  it 'removes leading whitespace' do
    subject.name = '  foo  '
    subject.validate
    expect(subject.name).to eq('foo')
  end

  it 'converts empty strings to null' do
    subject.stories = ''
    subject.validate
    expect(subject.stories).to be_nil
  end
end
