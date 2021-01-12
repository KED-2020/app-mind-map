# frozen_string_literal: true

require_relative '../helpers/spec_helper.rb'

describe 'Unit test of MindMap API gateway' do
  it 'must report alive status' do
    alive = MindMap::Gateway::Api.new(MindMap::App.config).alive?
    _(alive).must_equal true
  end

  it 'must return a unique inbox name' do
    # GIVEN A new inbox id is needed.

    # WHEN we request a new inbox id.
    res = MindMap::Gateway::Api.new(MindMap::App.config).get_new_inbox_id

    # THEN we should expect the id to be a 3-word Mnemonic
    URL_REGEX = /([a-zA-Z]+)-([a-zA-Z]+)-([a-zA-Z]+)/.freeze
    _(URL_REGEX.match?(res)).must_equal true
  end

  it 'must be able to add an inbox' do
    # GIVEN an inbox required fields
    inbox_id = MindMap::Gateway::Api.new(MindMap::App.config).get_new_inbox_id.to_s

    params = {
      'name' => 'Test',
      'description' => 'Test',
      # This is to prevent already created errors. We want inbox_id to
      # be unique on every call to POST.
      'url' => inbox_id
    }

    # WHEN we request to create an inbox
    res = MindMap::Gateway::Api.new(MindMap::App.config).add_inbox(params)

    # THEN we should see the inbox information
    _(res.success?).must_equal true
    data = res.parse

    _(data.keys).must_include 'name'
    _(data.keys).must_include 'description'
    _(data.keys).must_include 'url'
    _(data['url']).must_include inbox_id
  end

  it 'must not be able to add an inbox with an incorrectly formatted id' do
    # GIVEN an inbox with an id that is invalid
    params = {
      'name' => 'Test',
      'description' => 'Test',
      # This is to prevent already created errors. We want inbox_id to
      # be unique on every call to POST.
      'url' => 'def-131'
    }

    # WHEN we request to create an inbox
    res = MindMap::Gateway::Api.new(MindMap::App.config).add_inbox(params)

    # THEN we should see the error message
    _(res.success?).must_equal false
  end

  it 'must be able to get an existing inbox' do
    # GIVEN an inbox is in the database
    inbox_id = 'random-inbox-name'

    result = MindMap::Gateway::Api.new(MindMap::App.config).get_inbox(inbox_id)

    if result.success? == false
      params = {
        'name' => 'Test',
        'description' => 'Test',
        # This is to prevent already created errors. We want inbox_id to
        # be unique on every call to POST.
        'url' => inbox_id
      }

      MindMap::Gateway::Api.new(MindMap::App.config).add_inbox(params)
    end

    # WHEN we request this inbox
    res = MindMap::Gateway::Api.new(MindMap::App.config).get_inbox(inbox_id)

    # THEN we should see inbox information
    _(res.success?).must_equal true
    data = res.parse

    _(data.keys).must_include 'name'
    _(data.keys).must_include 'description'
    _(data.keys).must_include 'url'
    _(data['url']).must_include inbox_id
  end

  it 'must not be able to get a non-existent inbox' do
    # GIVEN inbox is not in the database

    # WHEN we request this inbox
    res = MindMap::Gateway::Api.new(MindMap::App.config).get_inbox(SAD_INBOX_ID)

    # THEN we should see the error message
    _(res.success?).must_equal false
  end

  it 'must be able to add a document' do
    # GIVEN no document is in the database

    # WHEN we request to add a document
    res = MindMap::Gateway::Api.new(MindMap::App.config).add_document(PROJECT_URL)

    # THEN we should see the document information
    _(res.success?).must_equal true
    data = res.parse
    _(data.keys).must_include 'id'
    _(data.keys).must_include 'origin_id'
    _(data.keys).must_include 'name'
    _(data.keys).must_include 'description'
    _(data.keys).must_include 'html_url'
    _(data['html_url']).must_equal PROJECT_URL
    _(data['name']).must_equal PROJECT_NAME
  end

  it 'must be able to get an existed document' do
    # GIVEN a document is in the database
    saved_document = MindMap::Gateway::Api.new(MindMap::App.config).add_document(PROJECT_URL)

    good_document_id = saved_document.parse['id']

    # WHEN we request this document
    res = MindMap::Gateway::Api.new(MindMap::App.config).get_document(good_document_id)

    # THEN we should see the document information
    _(res.success?).must_equal true
  end

  it 'must not be able to get a non-existent document' do
    # GIVEN document is not in the database
    sad_document_id = '123456789'

    # WHEN we request this document
    res = MindMap::Gateway::Api.new(MindMap::App.config).get_document(sad_document_id)

    # THEN we should see the error message
    _(res.success?).must_equal false
  end

  it 'must allow a user to save a suggestion' do
    # GIVEN an inbox with suggestions
    inbox_id = MindMap::Gateway::Api.new(MindMap::App.config).get_new_inbox_id.to_s

    params = {
      'name' => 'Test',
      'description' => 'Test',
      # This is to prevent already created errors. We want inbox_id to
      # be unique on every call to POST.
      'url' => inbox_id
    }

    MindMap::Gateway::Api.new(MindMap::App.config).add_inbox(params)
    inbox = MindMap::Gateway::Api.new(MindMap::App.config).get_inbox(inbox_id).parse
    suggestion_id = inbox['suggestions'].first['id']

    # WHEN we request to save a suggestion
    result = MindMap::Gateway::Api.new(MindMap::App.config).save_suggestion(inbox_id, suggestion_id)

    # THEN we should see the inbox suggestions count go down by 1
    _(result.success?).must_equal true

    updated_inbox = MindMap::Gateway::Api.new(MindMap::App.config).get_inbox(inbox_id).parse
    _(updated_inbox['suggestions'].count).must_equal inbox['suggestions'].count - 1
  end

  it 'must allow a user to delete a suggestion' do
    # GIVEN an inbox with suggestions
    inbox_id = MindMap::Gateway::Api.new(MindMap::App.config).get_new_inbox_id.to_s

    params = {
      'name' => 'Test',
      'description' => 'Test',
      # This is to prevent already created errors. We want inbox_id to
      # be unique on every call to POST.
      'url' => inbox_id
    }

    MindMap::Gateway::Api.new(MindMap::App.config).add_inbox(params)
    inbox = MindMap::Gateway::Api.new(MindMap::App.config).get_inbox(inbox_id).parse
    suggestion_id = inbox['suggestions'].first['id']

    # WHEN we request to save a suggestion
    result = MindMap::Gateway::Api.new(MindMap::App.config).remove_suggestion(inbox_id, suggestion_id)

    # THEN we should see the inbox suggestions count go down by 1
    _(result.success?).must_equal true

    updated_inbox = MindMap::Gateway::Api.new(MindMap::App.config).get_inbox(inbox_id).parse
    _(updated_inbox['suggestions'].count).must_equal inbox['suggestions'].count - 1
  end
end