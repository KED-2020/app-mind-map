# frozen_string_literal: true

require 'dry/transaction'

module MindMap
  module Service
    # Creates a subscription
    class AddSubscription
      include Dry::Transaction

      ADD_FAILURE = 'Cannot add subscription right now; please try again later'
      REIFY_FAILURE = 'Something unexpected happened; Please try again later.'

      step :validate_params
      step :create_subscription
      step :reify_subscription

      private

      def validate_params(input)
        if input.success?
          Success(input)
        else
          Failure(input.errors.values.join('; '))
        end
      end

      def create_subscription(input)
        result = MindMap::Gateway::Api.new(MindMap::App.config).add_subscription(input.to_h)

        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError
        Failure(ADD_FAILURE)
      end

      def reify_subscription(input)
        Representer::Inbox.new(OpenStruct.new)
          .from_json(input)
          .then { |subscription| Success(subscription) }
      rescue StandardError
        Failure(REIFY_FAILURE)
      end
    end
  end
end
