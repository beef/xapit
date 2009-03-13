module Xapit
  class IndexBlueprint
    attr_reader :text_attributes
    attr_reader :field_attributes
    attr_reader :facets
    
    def self.index_all(db = nil)
      @@instances.each_value do |blueprint|
        blueprint.index_into_database(db)
      end
    end
    
    def initialize(member_class, *args)
      @member_class = member_class
      @args = args
      @text_attributes = []
      @field_attributes = []
      @facets = []
      @@instances ||= {}
      @@instances[member_class] = self # TODO make this thread safe
    end
    
    def text(*attributes)
      @text_attributes += attributes
    end
    
    def field(*attributes)
      @field_attributes += attributes
    end
    
    def facet(*args, &block)
      @facets << FacetBlueprint.new(@facets.size, *args, &block)
    end
    
    def document_for(member)
      document = Xapian::Document.new
      document.data = "#{member.class}-#{member.id}"
      terms(member).each do |term|
        document.add_term(term)
      end
      values(member).each do |index, value|
        document.add_value(index, value)
      end
      document
    end
    
    def stripped_words(content)
      content.to_s.downcase.scan(/[a-z0-9]+/)
    end
    
    def terms(member)
      base_terms(member) + field_terms(member) + text_terms(member) + facet_terms(member)
    end
    
    def base_terms(member)
      ["C#{member.class}", "Q#{member.class}-#{member.id}"]
    end
    
    def text_terms(member)
      text_attributes.map do |name|
        stripped_words(member.send(name))
      end.flatten
    end
    
    def field_terms(member)
      field_attributes.map do |name|
        "X#{name}-#{member.send(name).to_s.downcase}"
      end
    end
    
    def facet_terms(member)
      facets.map do |facet|
        "F#{facet.identifier_for(member)}"
      end
    end
    
    def values(member)
      index = 0
      facet_terms(member).inject(Hash.new) do |hash, term|
        hash[index] = term
        index += 1
        hash
      end
    end
    
    def index_into_database(db = nil)
      db ||= Config.writable_database
      @member_class.each(*@args) do |member|
        db.add_document(document_for(member))
      end
    end
  end
end
