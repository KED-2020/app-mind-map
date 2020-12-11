# frozen_string_literal: true

require_relative '../helpers/spec_helper.rb'

describe 'Unit test of MindMap API gateway' do
  it 'must report alive status' do
    alive = MindMap::Gateway::Api.new(MindMap::App.config).alive?
    _(alive).must_equal true
  end
end

