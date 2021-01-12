# frozen_string_literal: true

require_relative '../helpers/spec_helper'

describe 'Integration test for the SaveSuggestion service and API gateway' do
  it 'must create a new inbox' do
    # GIVEN an inbox with suggestions
    inbox_id = MindMap::Gateway::Api.new(MindMap::App.config).get_new_inbox_id.to_s

    MindMap::Service::AddInbox.new.call(MindMap::Forms::NewInbox.new.call({
      'name' => 'Test',
      'description' => 'Test',
      # This is to prevent already created errors. We want inbox_id to
      # be unique on every call to POST.
      'url' => inbox_id
    }))

    inbox = MindMap::Service::GetInbox.new.call(inbox_id).value!
    suggestion_id = inbox.suggestions.first.id

    # WHEN we request to save a suggestion
    params = MindMap::Forms::SaveSuggestion.new.call({ inbox_id: inbox_id,
                                                       suggestion_id: suggestion_id.to_s })

    result = MindMap::Service::SaveSuggestion.new.call(params)

    # THEN we should see the inbox suggestions count go down by 1
    _(result.success?).must_equal true

    updated_inbox = MindMap::Service::GetInbox.new.call(inbox_id).value!

    _(updated_inbox.suggestions.count).must_equal inbox.suggestions.count - 1
  end
end
