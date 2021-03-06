# frozen_string_literal: true

require_relative '../helpers/acceptance_helper'
require_relative 'pages/inbox_page'
require_relative 'pages/home_page'

describe 'Project Page Acceptance Tests' do
  include PageObject::PageFactory

  DatabaseHelper.setup_database_cleaner

  before do
    DatabaseHelper.wipe_database
    @browser = Watir::Browser.new :chrome, headless: true    # need optionally install Xvfb on Mac
  end

  after do
    @browser.close
  end

  describe 'Visit Inbox page' do

    it '(Happy) should see search content' do
      # GIVEN: user adds an existent inbox URL and submit
      inbox = MindMap::Entity::Inbox.new(id: nil,
                                         name: 'Test Inbox',
                                         url: GOOD_INBOX_ID,
                                         description: 'A test inbox',
                                         suggestions: [])
      saved_inbox = MindMap::Repository::Inbox::For.klass(MindMap::Entity::Inbox).create(inbox)

      # WHEN: user goes to the inbox page
      visit(InboxPage, using_params: { inbox_id: GOOD_INBOX_ID }) do |page|

        # THEN: they should see the searching results
        _(page.all_elements_has_correct_text?).must_equal true
        _(page.includes_some_correct_suggestions?(SUGGESTION_NAMES)).must_equal true
      end
    end
  end
end
