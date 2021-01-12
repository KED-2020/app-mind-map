# frozen_string_literal: true

require 'dry/transaction'

module MindMap
  module Service
    # Saves a suggestion
    class DeleteSuggestion
      include Dry::Transaction

      SAVE_FAILURE = 'Cannot delete the suggestion right now; please try again later'

      step :validate_params
      step :save_suggestion

      private

      def validate_params(input)
        if input.success?
          Success(input)
        else
          Failure(input.errors.values.join('; '))
        end
      end

      def save_suggestion(input)
        value = input.to_h
        result = MindMap::Gateway::Api.new(MindMap::App.config).remove_suggestion(value[:inbox_id], value[:suggestion_id])
        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError
        Failure(SAVE_FAILURE)
      end
    end
  end
end
