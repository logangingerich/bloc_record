require 'sqlite3'

module Connection
  def connection
    if BlocRecord.platform == :sqlite3
       @connection = SQLite3::Platform.new(BlocRecord.database_filename)
     elsif BlocRecord.platform == :pg
       @connection = Postgres::Database.new(BlocRecord.database_filename)
     end
  end
end
