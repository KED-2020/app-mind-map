# frozen_string_literal: true

require 'http'

module MindMap
  module Gateway
    # Infrastructure to call MindMap API
    class Api
      def initialize(config)
        @config = config
        @request = Request.new(@config)
      end

      def alive?
        @request.get_root.success?
      end

      def get_inbox(inbox_url)
        @request.get_inbox(inbox_url)
      end

      def add_document(project_url)
        @request.add_document(project_url)
      end

      def get_document(document_id)
        @request.get_document(document_id)
      end

      # HTTP request transmitter
      class Request
        def initialize(config)
          @api_host = config.API_HOST
          @api_root = config.API_HOST + '/api/v1'
        end

        # get '/'
        def get_root
          call_api('get')
        end

        # get 'api/v1/inboxes/{inbox_url}'
        def get_inbox(inbox_url)
          call_api('get', ['inboxes', inbox_url])
        end

        # post 'api/v1/favorites/documents?html_url={PROJECT_URL}'
        def add_document(project_url)
          call_api('post', ['favorites', 'documents'], 'html_url' => project_url)
        end

        # get 'api/v1/favorites/documents/{document_id}'
        def get_document(document_id)
          call_api('get', ['favorites', 'documents', document_id])
        end

        private

        def params_str(params)
          params.map { |key, value| "#{key}=#{value}" }.join('&')
            .then { |str| str ? '?' + str : '' }
        end

        def call_api(method, resources = [], params = {})
          api_path = resources.empty? ? @api_host : @api_root
          url = [api_path, resources].flatten.join('/') + params_str(params)
          HTTP.headers('Accept' => 'application/json').send(method, url)
            .then { |http_response| Response.new(http_response) }
        rescue StandardError
          raise "Invalid URL request: #{url}"
        end
      end

      # Decorates HTTP responses with success/error
      class Response < SimpleDelegator
        NotFound = Class.new(StandardError)

        SUCCESS_CODES = (200..299).freeze

        def success?
          code.between?(SUCCESS_CODES.first, SUCCESS_CODES.last)
        end

        def message
          payload['message']
        end

        def payload
          body.to_s
        end
      end
    end
  end
end