# frozen_string_literal: true

module Views
  # View for a single keyword entity
  class Keyword
    def initialize(keyword, index = nil)
      @keyword = keyword
      @index = index
    end

    def id_str
      @keyword.id
    end

    def entity
      @keyword
    end

    def index_str
      "keyword[#{@index}]"
    end

    def name
      @keyword.name.capitalize
    end
  end
end
