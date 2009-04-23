module Xapit
  # This class wraps a Xapian::Query for convenience purposes. You will likely not need to use
  # this class unless you are trying to query the Xapian database directly.
  # You may be looking for Xapit::Collection instead.
  class Query
    attr_reader :default_options
    
    def initialize(query)
      @xapian_query = build_xapian_query(query)
      @default_options = { :offset => 0, :sort_descending => false }
    end
    
    def and_query(query)
      @xapian_query = Xapian::Query.new(Xapian::Query::OP_AND, @xapian_query, build_xapian_query(query)) unless query.blank?
      self
    end
    
    def or_query(query)
      @xapian_query = Xapian::Query.new(Xapian::Query::OP_OR, @xapian_query, build_xapian_query(query)) unless query.blank?
      self
    end
    
    def matchset(options = {})
      options.reverse_merge!(default_options)
      enquire = Xapian::Enquire.new(Config.database)
      if options[:sort_by_values]
        sorter = Xapian::MultiValueSorter.new
        options[:sort_by_values].each do |sort_value|
          sorter.add(sort_value, !!options[:sort_descending])
        end
        enquire.set_sort_by_key_then_relevance(sorter)
      end
      enquire.collapse_key = options[:collapse_key] if options[:collapse_key]
      enquire.query = @xapian_query
      enquire.mset(options[:offset], options[:limit])
    end
    
    def matches(options = {})
      matchset(options).matches
    end
    
    def count
      # a bit of a hack to get more accurate count estimate
      matchset(:limit => Config.database.doccount).matches_estimated
    end
    
    private
    
    def build_xapian_query(query)
      if query.kind_of? Xapian::Query
        query
      else
        Xapian::Query.new(Xapian::Query::OP_AND, [query].flatten)
      end
    end
  end
end
