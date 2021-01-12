# frozen_string_literal: true

require 'dry/transaction'

module MindMap
  module Service
    # Retrieves array of all listed project entities
    class GetSubscriptions
      include Dry::Transaction

      step :get_api_list
      step :reify_list

      private

      def get_api_list(inbox_id)
        Gateway::Api.new(MindMap::App.config)
          .get_subscriptions(inbox_id)
          .then do |result|
            result.success? ? Success(result.payload) : Failure(result.message)
          end
      rescue StandardError
        Failure('Could not access our API')
      end

      def reify_list(subscriptions_json)
        Representer::SubscriptionsList.new(OpenStruct.new)
          .from_json(subscriptions_json)
          .then { |subscriptions| Success(subscriptions) }
      rescue StandardError
        Failure('Could not parse response from API')
      end
    end
  end
end