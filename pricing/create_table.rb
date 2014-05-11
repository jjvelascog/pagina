require "sqlite3"

db = SQLite3::Database.new 'pricingdb.db'

# Create a database
rows = db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS pricing (
    idext int,
    sku VARCHAR(255),
    precio VARCHAR(255),
    fechaact VARCHAR(255),
    fechavig VARCHAR(255),
    costoprod VARCHAR(255),
    costotras VARCHAR(255),
    costoalm VARCHAR(255)
  );
SQL

