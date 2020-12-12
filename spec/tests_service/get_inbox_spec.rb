# frozen_string_literal: true

require_relative '../helpers/spec_helper'

describe 'Integration test of GetInbox service and API gateway' do
  # it 'must get an existed inbox' do
  #   # GIVEN an inbox is in the database
  #   # We need to provide "POST inboxes/" to test this function 
  #   # (otherwise we can only prepared the test inbox in the api backend)...

  #   # WHEN we request to get an inbox
  #   res = MindMap::Service::GetInbox.new.call(GOOD_INBOX_ID)

  #   # THEN we should see the inbox information
  #   _(res.success?).must_equal true
  #   data = res.value!
  #   _(data['url']).must_equal GOOD_INBOX_ID
  # end

  it 'must not get a nonexisted inbox' do
    # GIVEN inbox is not in the database

    # WHEN we request this inbox
    res = MindMap::Service::GetInbox.new.call(SAD_INBOX_ID)

    # THEN we should see the error message
    _(res.success?).must_equal false
  end
end
