# frozen_string_literal: true

require 'dry/transaction'

module MindMap
  module Service
    class GetDocument
      include Dry::Transaction

      step :request_document
      step :reify_document

      private

      def request_document(document_id)
        result = MindMap::Gateway::Api.new(MindMap::App.config).get_document(document_id)

        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError => e
        puts e.inspect + '\n' + e.backtrace
        Failure('Cannot get document right now; please try again later')
      end

      def reify_document(document_json)
        Representer::Document.new(OpenStruct.new)
          .from_json(document_json)
          .then { |document| Success(document) }
      rescue StandardError
        Failure('Cannot get document right now; please try again later')
      end
    end
  end
end
