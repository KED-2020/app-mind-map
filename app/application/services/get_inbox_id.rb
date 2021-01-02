# frozen_string_literal: true

require 'dry/monads'

module MindMap
  module Service
    # Requests an inbox id from the server.
    class GetInboxId
      include Dry::Monads::Result::Mixin

      def call
        result = MindMap::Gateway::Api.new(MindMap::App.config).get_new_inbox_id

        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError => e
        pp e
        Failure('Cannot get a new inbox ID; please try again later.')
      end
    end
  end
end