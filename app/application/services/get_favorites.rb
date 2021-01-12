# frozen_string_literal: true

require 'dry/transaction'

module MindMap
  module Service
    # Retrieves array of all listed favorites entities
    class GetFavorites
      include Dry::Transaction

      step :get_api_list
      step :reify_list

      private

      def get_api_list(inbox_id)
        Gateway::Api.new(MindMap::App.config)
          .get_favorites(inbox_id)
          .then do |result|
            result.success? ? Success(result.payload) : Failure(result.message)
          end
      rescue StandardError
        Failure('Could not access our API')
      end

      def reify_list(favorites_json)
        Representer::DocumentsList.new(OpenStruct.new)
          .from_json(favorites_json)
          .then { |favorites| Success(favorites) }
      rescue StandardError
        Failure('Could not parse response from API')
      end
    end
  end
end