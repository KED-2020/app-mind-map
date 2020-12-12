# frozen_string_literal: true

require_relative '../helpers/spec_helper'

describe 'Integration test of AddDocument service and API gateway' do
  it 'must add a document' do
    # WHEN we request to add a document
    url_request = MindMap::Forms::AddDocument.new.call(html_url: PROJECT_URL)
    res =  MindMap::Service::AddDocument.new.call(url_request)

    # THEN we should see the document information
    _(res.success?).must_equal true
    data = res.value!
    _(data['html_url']).must_equal PROJECT_URL
    _(data['name']).must_equal PROJECT_NAME
  end
end
