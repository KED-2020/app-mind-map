# frozen_string_literal: true

require_relative '../helpers/spec_helper.rb'

describe 'Integration test of GetFavorites service and API gateway' do
  it 'must return a list of documents' do
    # GIVEN a document is available for an inbox
    inbox_id = MindMap::Gateway::Api.new(MindMap::App.config).get_new_inbox_id.to_s
    inbox = MindMap::Service::AddInbox.new.call(MindMap::Forms::NewInbox.new.call({
      'name' => 'Test',
      'description' => 'Test',
      'url' => inbox_id
    })).value!

    # We load the inbox to load the necessary favorites
    suggestion_id = MindMap::Service::GetInbox.new.call(inbox_id).value!.suggestions.first.id.to_s
    # Save the suggestion
    params = MindMap::Forms::SaveSuggestion.new.call('inbox_id' => inbox_id, 'suggestion_id' => suggestion_id)
    MindMap::Service::SaveSuggestion.new.call(params)

    # WHEN we request a list of favorites
    result = MindMap::Service::GetFavorites.new.call(inbox_id)

    # THEN we should see a single favorites in the list
    _(result.success?).must_equal true
    list = result.value!

    _(list.documents.count).must_equal 1
    _(list.documents.first.id.to_s).must_equal suggestion_id
  end

  it 'must return and empty list if no favorites exist for an inbox' do
    # GIVEN no subscriptions are available for an inbox
    inbox_id = MindMap::Gateway::Api.new(MindMap::App.config).get_new_inbox_id.to_s
    inbox = MindMap::Service::AddInbox.new.call(MindMap::Forms::NewInbox.new.call({
      'name' => 'Test',
      'description' => 'Test',
      'url' => inbox_id
    })).value!

    # WHEN we request a list of favorites
    result = MindMap::Service::GetFavorites.new.call(inbox_id)

    # THEN we should see a no favorites in the list
    _(result.success?).must_equal true
    list = result.value!
    _(list.documents.count).must_equal 0
  end
end
