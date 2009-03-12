module Xapit
  class Collection
    NON_DELEGATE_METHODS = %w(nil? send object_id class extend size paginate first last empty? respond_to?).to_set
    [].methods.each do |m|
      delegate m, :to => :results unless m =~ /^__/ || NON_DELEGATE_METHODS.include?(m.to_s)
    end
    
    def initialize(member_class, search_text, options = {})
      @member_class = member_class
      @search_text = search_text
      @options = options
    end
    
    def results
      @results ||= fetch_results
    end
    
    def size
      matchset(0, 1).matches_estimated
    end
    alias_method :total_entries, :size
    
    def empty?
      @results ? @results.empty? : size.zero?
    end
    
    def first
      fetch_results(0, 1).first
    end
    
    def last
      fetch_results(size-1, 1).last
    end
    
    def search(keywords, options = {})
      collection = Collection.new(@member_class, keywords, options.reverse_merge(:database => @options[:database]))
      collection.base_query = query
      collection
    end
    
    def base_query=(base_query)
      @base_query = base_query
    end
    
    def current_page
      @options[:page] ? @options[:page].to_i : 1
    end
    
    def per_page
      @options[:per_page] ? @options[:per_page].to_i : 20
    end
    
    def total_pages
      (total_entries / per_page.to_f).ceil
    end
    
    def previous_page
      current_page > 1 ? (current_page - 1) : nil
    end
    
    def next_page
      current_page < total_pages ? (current_page + 1): nil
    end
    
    private
    
    def matchset(offset = nil, limit = nil)
      enquire = Xapian::Enquire.new(database)
      enquire.query = query
      enquire.mset(offset || per_page*(current_page-1), limit || per_page)
    end
    
    def query
      if (search_terms + condition_terms).empty?
        base_query
      else
        Xapian::Query.new(Xapian::Query::OP_AND, base_query, Xapian::Query.new(Xapian::Query::OP_AND, search_terms + condition_terms))
      end
    end
    
    def base_query
      @base_query || Xapian::Query.new(Xapian::Query::OP_AND, ["C" + @member_class.name])
    end
    
    def fetch_results(offset = nil, limit = nil)
      matchset(offset, limit).matches.map do |match|
        member = @member_class.find(match.document.data.split('-').last)
        member.xapit_relevance = match.percent
        member
      end
    end
    
    def search_terms
      @search_text.split.map { |term| term.downcase }
    end
    
    def condition_terms
      if @options[:conditions]
        @options[:conditions].map do |name, value|
          "X#{name}-#{value.downcase}"
        end
      else
        []
      end
    end
    
    def database
      # TODO fetch database from global config
      @options[:database]
    end
  end
end
