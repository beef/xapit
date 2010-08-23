module Xapit
  # Singleton class for storing Xapit configuration settings. Currently this only includes the database path.
  class Config
    class << self
      attr_reader :options
      
      # See Xapit#setup
      def setup(options = {})
        if @options && options[:database_path] != @options[:database_path]
          @database = nil
          @writable_database = nil
        end
        @options = options.reverse_merge(default_options)
      end
      
      def default_options
        {
          :indexer => SimpleIndexer,
          :query_parser => ClassicQueryParser,
          :spelling => true,
          :stemming => "english"
        }
      end
      
      # See if setup options are already set.
      def setup?
        @options
      end
      
      # The configured path to the database.
      def path
        @options[:database_path]
      end
      
      def query_parser
        @options[:query_parser]
      end
      
      def indexer
        @options[:indexer]
      end
      
      def spelling?
        @options[:spelling]
      end
      
      def stemming
        @options[:stemming]
      end
      
      def breadcrumb_facets?
        @options[:breadcrumb_facets]
      end
      
      # Fetch Xapian::Database object at configured path. Database is stored in memory.
      def database
        database = @writable_database || (@database ||= Xapian::Database.new(path))
        
        if self.expired?
          puts 'reloaded'
          database.reopen 
        end
        
        database
      end
      
      # A SHA1 hash to monitor if database is changed
      #  SHA1 of filesize and last modified timestmp of record database file
      def expired?
        expired = false
              
        file = Pathname.new(path) + 'record.DB'
        return false unless file.exist?
        
        hash = Digest::SHA1.hexdigest(file.size.to_s + file.mtime.to_s)
        
        if @db_hash and @db_hash != hash
          expired = true
        end
        @db_hash = hash

        return expired
      end
      
      # Fetch Xapian::WritableDatabase object at configured path. Database is stored in memory.
      # Creates the database directory if needed.
      def writable_database
        FileUtils.mkdir_p(File.dirname(path)) unless File.exist?(File.dirname(path))
        @writable_database ||= Xapian::WritableDatabase.new(path, Xapian::DB_CREATE_OR_OPEN)
      end
      
      # Removes the configured database file and clears the stored one in memory.
      def remove_database
        FileUtils.rm_rf(path) if File.exist? File.join(path, "record.DB")
        @database = nil
        @writable_database = nil
      end
      
      # Clear the current database from memory. Unfortunately this is a hack because
      # Xapian doesn't provide a "close" method on the database. We just have to hope
      # no other references are lying around.
      def close_database
        @database = nil
        @writable_database = nil
        GC.start
      end
    end
  end
end
