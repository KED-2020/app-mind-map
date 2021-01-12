# frozen_string_literal: true

require_relative 'subscription'

module Views
  # View for a a list of project entities
  class SubscriptionsList
    def initialize(subscriptions)
      @subscriptions = subscriptions.map.with_index { |sub, i| Subscription.new(sub, i) }
    end

    def each
      @subscriptions.each do |sub|
        yield sub
      end
    end

    def any?
      @subscriptions.any?
    end
  end
end