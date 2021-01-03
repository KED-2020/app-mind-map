# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

require 'yaml'
require 'minitest/autorun'
require 'minitest/rg'

require_relative '../../init'

# Helper methods
def homepage
  MindMap::App.config.APP_HOST
end

GOOD_INBOX_ID = 'wonderful-day-today'
SAD_INBOX_ID = '54321'
SUGGESTION_NAMES = ['tensorflow', 'TensorFlow', 'TensorFlow-Examples']

PROJECT_OWNER = 'derrxb'
PROJECT_NAME = 'derrxb'
PROJECT_URL = 'https://github.com/derrxb/derrxb'