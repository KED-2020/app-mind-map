# frozen_string_literal: true

require 'base64'
require 'dry/monads/result'
require 'json'

module MindMap
  module Gateway
    module Value
      # List request parser
      class KeywordsList
        include Dry::Monads::Result::Mixin

        # Use in client App to create params to send
        def self.to_encoded(list)
          Base64.urlsafe_encode64(list.to_json)
        end

        # Use in tests to create a WatchedList object from a list
        def self.to_request(list)
          WatchedList.new('keywords' => to_encoded(list))
        end
      end
    end
  end
end
