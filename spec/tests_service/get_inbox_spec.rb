# frozen_string_literal: true

require_relative '../helpers/spec_helper'

describe 'Integration test of GetInbox service and API gateway' do
  it 'must get an existed inbox' do
    # GIVEN an inbox is in the database
    INBOX_ID = 'random-inbox-name'

    result = MindMap::Gateway::Api.new(MindMap::App.config).get_inbox(INBOX_ID)

    if result.success? == false
      params = {
        'name' => 'Test',
        'description' => 'Test',
        # This is to prevent already created errors. We want inbox_id to
        # be unique on every call to POST.
        'url' => INBOX_ID
      }

      MindMap::Gateway::Api.new(MindMap::App.config).add_inbox(params)
    end

    # WHEN we request to get an inbox
    res = MindMap::Service::GetInbox.new.call(INBOX_ID)

    # THEN we should see the inbox information
    _(res.success?).must_equal true
    data = res.value!
    _(data['url']).must_equal INBOX_ID
  end

  it 'must not get a non-existent inbox' do
    # GIVEN inbox is not in the database

    # WHEN we request this inbox
    res = MindMap::Service::GetInbox.new.call(SAD_INBOX_ID)

    # THEN we should see the error message
    _(res.success?).must_equal false
  end
end