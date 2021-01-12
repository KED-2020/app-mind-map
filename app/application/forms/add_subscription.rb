# frozen_string_literal: true

require 'dry-validation'

module MindMap
  module Forms
    class AddSubscription < Dry::Validation::Contract
      URL_REGEX = /([a-zA-Z]+)-([a-zA-Z]+)-([a-zA-Z]+)/.freeze

      params do
        required(:inbox_id).filled(:string)
        required(:name).filled(:string)
        required(:description).filled(:string)
      end

      rule(:inbox_id) do
        unless URL_REGEX.match?(value)
          key.failure('is an invalid inbox id.')
        end
      end
    end
  end
end