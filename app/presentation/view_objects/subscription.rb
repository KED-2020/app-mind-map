# frozen_string_literal: true

require_relative 'keyword'

module Views
  # View for a single subscription entity
  class Subscription
    def initialize(subscription, index = nil)
      @subscription = subscription
      @index = index
    end

    def id_str
      @subscription.id
    end

    def entity
      @subscription
    end

    def index_str
      "subscription[#{@index}]"
    end

    def name
      @subscription.name
    end

    def description
      @subscription.description
    end

    def keywords
      @subscription.keywords.map.with_index do |keyword, i|
        Keyword.new(keyword, i)
      end
    end

    def any_keywords?
      @subscription.keywords.any?
    end
  end
end
