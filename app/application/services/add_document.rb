# frozen_string_literal: true

require 'dry/transaction'

module MindMap
  module Service
    class AddDocument
      include Dry::Transaction

      step :validate_url
      step :request_document
      step :reify_document

      private

      def validate_url(input)
        if input.success?
          document_url = input[:html_url]
          Success(document_url: document_url)
        else
          Failure(input.errors.values.join('; '))
        end
      end

      def request_document(input)
        result = MindMap::Gateway::Api.new(MindMap::App.config).add_document(input[:document_url])

        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError => e
        puts e.inspect + '\n' + e.backtrace
        Failure('Cannot add document right now; please try again later')
      end

      def reify_document(document_json)
        Representer::Document.new(OpenStruct.new)
          .from_json(document_json)
          .then { |document| Success(document) }
      rescue StandardError
        Failure('Cannot add document right now; please try again later')
      end
    end
  end
end
