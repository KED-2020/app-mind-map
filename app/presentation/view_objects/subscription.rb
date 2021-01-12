# frozen_string_literal: true

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
      ['Bitcoin', 'Python'].each do |keyword|
        yield keyword
      end
    end
  end
end
