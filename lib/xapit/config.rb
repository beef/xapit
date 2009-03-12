module Xapit
  class Config
    class << self
      def setup(options)
        reset
        @options = options
      end
      
      def reset
        @options = nil
        @database = nil
        @writable_database = nil
      end
      
      def setup?
        @options
      end
      
      def path
        @options[:database_path]
      end
      
      def database
        @writable_database || (@database ||= Xapian::Database.new(path))
      end
      
      def writable_database
        FileUtils.mkdir_p(File.dirname(path)) unless File.exist?(File.dirname(path))
        @writable_database ||= Xapian::WritableDatabase.new(path, Xapian::DB_CREATE_OR_OPEN)
      end
    end
  end
end
