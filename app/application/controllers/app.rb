# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'
require 'delegate'

module MindMap
  # Environment-specific configuration
  class App < Roda
    plugin :halt
    plugin :flash
    plugin :all_verbs # allows DELETE and other HTTP verbs beyond GET/POST
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :assets, css: 'style.css', path: 'app/presentation/assets'
    plugin :partials

    use Rack::MethodOverride # for other HTTP verbs (with plugin all_verbs)

    # rubocop:disable Metrics/BlockLength
    route do |routing|
      routing.assets # Load CSS

      # GET /
      routing.root do
        view 'home'
      end

      # GET /document_nil
      routing.on 'document_nil' do
        view 'document_nil'
      end

      # Inbox
      routing.on 'inbox' do
        routing.on 'new' do
          routing.is do
            # GET /inboxes/new => Create Inbox Form
            routing.get do
              result = Service::GetInboxId.new.call

              if result.failure?
                flash[:error] = result.failure
                routing.redirect '/'
              end

              view 'new_inbox', locals: { inbox_id: result.value! }
            end
          end
        end

         # GET /inbox/{inbox_id}
        routing.on String do |inbox_id|
          @inbox_id = inbox_id

          routing.on 'suggestions' do
            routing.on String do |suggestion_id|
              routing.post do
                params = Forms::SaveSuggestion.new.call('inbox_id' => @inbox_id,
                                                        'suggestion_id' => suggestion_id)

                result = Service::SaveSuggestion.new.call(params)

                if result.failure?
                  flash[:error] = result.failure
                end

                flash[:success] = 'Suggestion has been saved. This can now be found in `favorites`.'
                routing.redirect "/inbox/#{@inbox_id}"
              end

              routing.delete do
                params = Forms::DeleteSuggestion.new.call('inbox_id' => @inbox_id,
                                                          'suggestion_id' => suggestion_id)

                result = Service::DeleteSuggestion.new.call(params)

                if result.failure?
                  flash[:error] = result.failure
                end

                routing.redirect "/inbox/#{@inbox_id}"
              end
            end
          end

          routing.get do
            result = Service::GetInbox.new.call(inbox_id)

            if result.failure?
              flash[:error] = result.failure
              routing.redirect '/'
            end

            inbox = result.value!
            viewable_inbox = Views::Inbox.new(inbox, [])

            # Show the user their inbox
            view 'inbox', locals: { inbox: viewable_inbox }
          end
        end

        # POST /inboxes => Create Inbox
        routing.is do
          routing.post do
            inbox_params = Forms::NewInbox.new.call(routing.params)

            result = Service::AddInbox.new.call(inbox_params)

            if result.failure?
              flash[:error] = result.failure
              routing.redirect "/inbox/new"
            end

            routing.redirect "/inbox/#{routing.params["url"]}"
          end

          routing.get do
            inbox_id = routing.params['inbox_id']

            if inbox_id.nil? || inbox_id.empty?
              flash[:error] = 'You need to provide an inbox id'
              routing.redirect '/'
            end

            # Redirect to the get request
            routing.redirect "/inbox/#{inbox_id}"
          end
        end
      end

      # Favorites
      routing.on 'favorites' do
        routing.on 'documents' do
          # POST /favorites/documents
          routing.post do
            html_url = Forms::AddDocument.new.call(routing.params)

            result = Service::AddDocument.new.call(html_url)

            if result.failure?
              flash[:error] = result.failure
              routing.redirect '/favorites'
            end

            # Show the user their favorites
            routing.redirect '/favorites'
          end

          # GET /favorites/documents/{document_id}
          routing.on String do |document_id|
            routing.get do
              result = Service::GetDocument.new.call(document_id)

              if result.failure?
                flash[:error] = result.failure
                routing.redirect '/document_nil'
              end

              document = result.value!

              view 'document', locals: { document: document }
            end
          end
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
