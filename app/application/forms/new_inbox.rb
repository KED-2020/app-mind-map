# frozen_string_literal: true

require 'dry-validation'

module MindMap
  module Forms
    class NewInbox < Dry::Validation::Contract
      URL_REGEX = /([a-zA-Z]+)-([a-zA-Z]+)-([a-zA-Z]+)/.freeze

      params do
        required(:url).filled(:string)
        required(:name).filled(:string)
        required(:description).filled(:string)
      end

      rule(:url) do
        unless URL_REGEX.match?(value)
          key.failure('is an invalid project name')
        end
      end
    end
  end
end