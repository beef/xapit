module Xapit
  class ClassicQueryParser < AbstractQueryParser
    def xapian_query_from_text(text)
      xapian_parser.parse_query(text, Xapian::QueryParser::FLAG_WILDCARD | Xapian::QueryParser::FLAG_PHRASE | Xapian::QueryParser::FLAG_BOOLEAN | Xapian::QueryParser::FLAG_LOVEHATE)
    end
    
    def xapian_parser
      @xapian_parser ||= build_xapian_parser
    end
    
    def build_xapian_parser
      parser = Xapian::QueryParser.new
      parser.database = Config.database
      parser.stemmer = Xapian::Stem.new(Config.stemming)
      parser.stemming_strategy = Xapian::QueryParser::STEM_SOME
      parser.default_op = Xapian::Query::OP_AND
      parser
    end
  end
end
