# frozen_string_literal: true

require_relative '../helpers/spec_helper'

describe 'Integration test for the AddInbox service and API gateway' do
  it 'must create a new inbox' do
    # GIVEN an inbox with the required fields
    inbox_id = MindMap::Gateway::Api.new(MindMap::App.config).get_new_inbox_id.to_s

    params = MindMap::Forms::NewInbox.new.call({
      'name' => 'Test',
      'description' => 'Test',
      # This is to prevent already created errors. We want inbox_id to
      # be unique on every call to POST.
      'url' => inbox_id
    })

    # WHEN we request to create an inbox
    res = MindMap::Service::AddInbox.new.call(params)

    # THEN we should see the inbox information
    _(res.success?).must_equal true
    inbox = res.value!

    _(inbox.name).must_equal 'Test'
    _(inbox.description).must_equal 'Test'
    _(inbox.url).must_equal inbox_id
  end
end
