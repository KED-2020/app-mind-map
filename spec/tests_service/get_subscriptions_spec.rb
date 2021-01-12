# frozen_string_literal: true

require_relative '../helpers/spec_helper.rb'

describe 'Integration test of GetSubscriptions service and API gateway' do
  it 'must return a list of subscriptions' do
    # GIVEN a subscription is available for an inbox
    inbox_id = MindMap::Gateway::Api.new(MindMap::App.config).get_new_inbox_id.to_s
    inbox = MindMap::Service::AddInbox.new.call(MindMap::Forms::NewInbox.new.call({
      'name' => 'Test',
      'description' => 'Test',
      'url' => inbox_id
    })).value!

    MindMap::Service::AddSubscription.new.call(MindMap::Forms::AddSubscription.new.call({
      'name' => 'test',
      'description' => 'test',
      'inbox_id' => inbox_id
    }))

    # WHEN we request a list of projects
    result = MindMap::Service::GetSubscriptions.new.call(inbox_id)

    # THEN we should see a single project in the list
    _(result.success?).must_equal true
    list = result.value!
    _(list.subscriptions.count).must_equal 1
    # _(list.subscriptions.first).must_equal USERNAME
  end

  it 'must return and empty list if we specify none' do
    # GIVEN no subscriptions are available for an inbox
    inbox_id = MindMap::Gateway::Api.new(MindMap::App.config).get_new_inbox_id.to_s
    inbox = MindMap::Service::AddInbox.new.call(MindMap::Forms::NewInbox.new.call({
      'name' => 'Test',
      'description' => 'Test',
      'url' => inbox_id
    })).value!

    # WHEN we request a list of projects
    result = MindMap::Service::GetSubscriptions.new.call(inbox_id)

    # THEN we should see a no projects in the list
    _(result.success?).must_equal true
    list = result.value!
    _(list.subscriptions.count).must_equal 0
  end
end