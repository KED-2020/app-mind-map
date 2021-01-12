# frozen_string_literal: true

require 'dry-validation'

module MindMap
  module Forms
    class SaveSuggestion < Dry::Validation::Contract
      INBOX_ID_REGEX = /([a-zA-Z]+)-([a-zA-Z]+)-([a-zA-Z]+)/.freeze

      params do
        required(:inbox_id).filled(:string)
        required(:suggestion_id).filled(:string)
      end

      rule(:inbox_id) do
        unless INBOX_ID_REGEX.match?(value)
          key.failure('is an invalid id. You need a unique id for this inbox.')
        end
      end
    end
  end
end