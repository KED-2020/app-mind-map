# frozen_string_literal: true

require_relative '../helpers/spec_helper'

describe 'Integration test for the AddSubscription service and API gateway' do
  it 'must create a subscription for an inbox' do
    # GIVEN an inbox with no subscriptions
    inbox_id = MindMap::Gateway::Api.new(MindMap::App.config).get_new_inbox_id.to_s
    inbox = MindMap::Service::AddInbox.new.call(MindMap::Forms::NewInbox.new.call({
      'name' => 'Test',
      'description' => 'Test',
      'url' => inbox_id
    })).value!

    # WHEN we request to create a subscription
    params = MindMap::Forms::AddSubscription.new.call({
      'name' => 'test',
      'description' => 'test',
      'inbox_id' => inbox_id
    })
    result = MindMap::Service::AddSubscription.new.call(params)

    # THEN we should see the inbox subscription
    _(result.success?).must_equal true
    subscription = result.value!

    _(subscription.name).must_equal 'test'
    _(subscription.description).must_equal 'test'
  end
end
