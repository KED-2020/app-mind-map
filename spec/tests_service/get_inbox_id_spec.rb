# frozen_string_literal: true

require_relative '../helpers/spec_helper'

describe 'Integration test for the GetInboxId service and API gateway' do
  it 'must create a new inbox' do
    # GIVEN that the user want an inbox id
    # WHEN we request to get an inbox id
    res = MindMap::Service::GetInboxId.new.call

    # THEN we should see the new inbox id
    _(res.success?).must_equal true
    inbox = res.value!

    _(/([a-zA-Z]+)-([a-zA-Z]+)-([a-zA-Z]+)/.freeze.match?(inbox)).must_equal true
  end
end
