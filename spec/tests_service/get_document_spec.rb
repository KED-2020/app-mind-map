# frozen_string_literal: true

require_relative '../helpers/spec_helper'

describe 'Integration test of GetDocument service and API gateway' do
  it 'must get a document' do
    # GIVEN document is in the database
    url_request = MindMap::Forms::AddDocument.new.call(html_url: PROJECT_URL)
    res =  MindMap::Service::AddDocument.new.call(url_request).value!

    GOOD_DOCUMENT_ID = res.id

    # WHEN we request this document
    res = MindMap::Service::GetDocument.new.call(GOOD_DOCUMENT_ID)

    # THEN we should see the document information
    _(res.success?).must_equal true
    data = res.value!
    _(data['html_url']).must_equal PROJECT_URL
    _(data['name']).must_equal PROJECT_NAME
  end

  it 'must not get a non-existent document' do
    # GIVEN document is not in the database
    SAD_DOCUMENT_ID = '123456789'

    # WHEN we request this document
    res = MindMap::Service::GetDocument.new.call(SAD_DOCUMENT_ID)

    # THEN we should see the error message
    _(res.success?).must_equal false
  end
end