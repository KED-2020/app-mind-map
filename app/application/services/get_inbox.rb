# frozen_string_literal: true

require 'dry/transaction'

module MindMap
  module Service
    class GetInbox
      include Dry::Transaction

      step :request_inbox
      step :reify_inbox

      private

      def request_inbox(inbox_id)
        result = MindMap::Gateway::Api.new(MindMap::App.config).get_inbox(inbox_id)

        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError => e
        puts e.inspect + '\n' + e.backtrace
        Failure('Cannot get inbox right now; please try again later')
      end

      def reify_inbox(inbox_json)
        Representer::Inbox.new(OpenStruct.new)
          .from_json(inbox_json)
          .then { |inbox| Success(inbox) }
      rescue StandardError
        Failure('Cannot get inbox right now; please try again later')
      end
    end
  end
end
