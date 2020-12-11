# frozen_string_literal: true

require_relative '../helpers/spec_helper.rb'

describe 'Unit test of MindMap API gateway' do
  it 'must report alive status' do
    alive = MindMap::Gateway::Api.new(MindMap::App.config).alive?
    _(alive).must_equal true
  end

  # it 'must be able to get an existed inbox' do
  #   # GIVEN an inbox is in the database
  #   # We need to provide "POST inboxes/" to test this function 
  #   # (otherwise we can only prepared the test inbox in the api backend)...

  #   # WHEN we request this inbox
  #   res = MindMap::Gateway::Api.new(MindMap::App.config).get_inbox(GOOD_INBOX_ID)

  #   # THEN we should see inbox information
  #   _(res.success?).must_equal true
  #   data = res.parse
  #   _(data.keys).must_include 'name'
  #   _(data.keys).must_include 'description'
  #   _(data.keys).must_include 'url'
  #   _(data['url']).must_include GOOD_INBOX_ID
  # end

  it 'must not be able to get a nonexisted inbox' do
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
    _(data.keys).must_include 'origin_id'
    _(data.keys).must_include 'name'
    _(data.keys).must_include 'description'
    _(data.keys).must_include 'html_url'
    _(data['html_url']).must_equal PROJECT_URL
    _(data['name']).must_equal PROJECT_NAME
  end

  # it 'must be able to get an existed document' do
  #   # GIVEN a document is in the database
  #   GOOD_DOCUMENT_ID = '??'

  #   # WHEN we request this document
  #   res = MindMap::Gateway::Api.new(MindMap::App.config).get_document(GOOD_DOCUMENT_ID)

  #   # THEN we should see the document information
  #   _(res.success?).must_equal true
  # end

  it 'must not be able to get a nonexisted document' do
    # GIVEN document is not in the database
    SAD_DOCUMENT_ID = '123456789'

    # WHEN we request this document
    res = MindMap::Gateway::Api.new(MindMap::App.config).get_document(SAD_DOCUMENT_ID)

    # THEN we should see the error message
    _(res.success?).must_equal false
  end
end

