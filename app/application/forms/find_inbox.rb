# frozen_string_litral: true

require 'dry-validation'

module MindMap
  module Forms
    class FindInbox < Dry::Validation::Contract
      URL_REGEX = /([a-zA-Z]+)-([a-zA-Z]+)-([a-zA-Z]+)/.freeze

      params do
        required(:inbox_id).filled(:string)
      end

      rule(:inbox_id) do
        unless INBOX_REGEX.match?(value)
          key.failure('is an invalid inbox id, should be three-word mnemonic')
        end
      end
    end
  end
end
