# frozen_string_literal: true

require 'http'
require_relative 'list_request'

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

      def add_inbox(inbox)
        @request.add_inbox(inbox)
      end

      def get_new_inbox_id
        @request.get_new_inbox_id
      end

      def add_document(project_url)
        @request.add_document(project_url)
      end

      def get_document(document_id)
        @request.get_document(document_id)
      end

      def save_suggestion(inbox_id, suggestion_id)
        @request.save_suggestion(inbox_id, suggestion_id)
      end

      def remove_suggestion(inbox_id, suggestion_id)
        @request.remove_suggestion(inbox_id, suggestion_id)
      end

      def add_subscription(params)
        @request.add_subscription(
          params.merge(keywords: Value::KeywordsList.to_encoded(params[:keywords]))
        )
      end

      def get_subscriptions(inbox_id)
        @request.get_subscriptions(inbox_id)
      end

      def get_favorites(inbox_id)
        @request.get_favorites(inbox_id)
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

        def add_inbox(inbox)
          post_api(['inboxes'], inbox)
        end

        # get 'api/v1/inboxes/mnemonics'
        def get_new_inbox_id
          call_api('get', ['inboxes', 'mnemonics'])
        end

        # post 'api/v1/documents?html_url={PROJECT_URL}'
        def add_document(project_url)
          post_api(['documents'], { 'html_url' => project_url })
        end

        # get 'api/v1/documents/{document_id}'
        def get_document(document_id)
          call_api('get', ['documents', document_id])
        end

        # post 'api/v1/inboxes/:inbox_id/suggestions/:suggestion_id
        def save_suggestion(inbox_id, suggestion_id)
          call_api('post', ['inboxes', inbox_id, 'suggestions', suggestion_id])
        end

        # delete 'api/v1/inboxes/:inbox_id/suggestions/:delete_id
        def remove_suggestion(inbox_id, suggestion_id)
          call_api('delete', ['inboxes', inbox_id, 'suggestions', suggestion_id])
        end

        # post 'api/v1/inboxes/:inbox_id/subscriptions`
        def add_subscription(params)
          post_api(['inboxes', params[:inbox_id], 'subscriptions'], params)
        end

        def get_subscriptions(inbox_id)
          call_api('get', ['inboxes', inbox_id, 'subscriptions'])
        end

        def get_favorites(inbox_id)
          call_api('get', ['inboxes', inbox_id, 'documents'])
        end

        private

        def params_str(params)
          params.map { |key, value| "#{key}=#{value}" }.join('&')
            .then { |str| str ? '?' + str : '' }
        end

        def post_api(resources = [], params = {})
          api_path = resources.empty? ? @api_host : @api_root
          url = [api_path, resources].flatten.join('/')

          HTTP.headers('Accept' => 'application/json').post(url, :form => params)
            .then { |http_response| Response.new(http_response) }
        rescue StandardError
          raise "Invalid URL request: #{url}"
        end

        def call_api(method, resources = [], params = {})
          api_path = resources.empty? ? @api_host : @api_root
          url = [api_path, resources].flatten.join('/')
          url = url + params_str unless params.empty?

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

        def failure?
          !success?
        end

        def ok?
          code == 200
        end

        def added?
          code == 201
        end

        def processing?
          code == 202
        end

        def message
          JSON.parse(payload)['message']
        end

        def payload
          body.to_s
        end
      end
    end
  end
end