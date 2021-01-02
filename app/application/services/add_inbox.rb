# frozen_string_literal: true

require 'dry/transaction'

module MindMap
  module Service
    class AddInbox
      include Dry::Transaction

      ADD_FAILURE = 'Cannot add inbox right now; please try again later'
      REIFY_FAILURE = 'Something unexpected happened; Please try again later.'

      step :validate_params
      step :create_inbox
      step :reify_inbox

      private

      def validate_params(input)
        if input.success?
          Success(input)
        else
          Failure(input.errors.values.join('; '))
        end
      end

      def create_inbox(input)
        result = MindMap::Gateway::Api.new(MindMap::App.config).add_inbox(input.to_h)

        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError => e
        Failure(ADD_FAILURE)
      end

      def reify_inbox(input)
        Representer::Inbox.new(OpenStruct.new)
          .from_json(input)
          .then { |inbox| Success(inbox) }
      rescue StandardError
        Failure(REIFY_FAILURE)
      end
    end
  end
end