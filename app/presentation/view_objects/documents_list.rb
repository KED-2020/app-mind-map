# frozen_string_literal: true

require_relative 'document'

module Views
  # View for a a list of project entities
  class DocumentsList
    def initialize(documents)
      @documents = documents.map.with_index { |fav, i| Document.new(fav, i) }
    end

    def total
      @documents.count
    end

    def each
      @documents.each do |sub|
        yield sub
      end
    end

    def any?
      @documents.any?
    end
  end
end