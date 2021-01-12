# frozen_string_literal: true

module Views
  # View for a single document entity
  class Document
    def initialize(document, index = nil)
      @document = document
      @index = index
    end

    def id_str
      @document.id
    end

    def entity
      @document
    end

    def index_str
      "document[#{@index}]"
    end

    def name
      @document.name.capitalize
    end

    def description
      @document.description
    end

    def source
      @document.html_url
    end
  end
end
