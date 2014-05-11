require "sqlite3"
require 'csv'

db = SQLite3::Database.new 'pricingdb.db'

text=File.open('Pricing.csv').read

csv = <<CSV 

CSV

begin#NEW
  db.transaction#NEW

  db.execute "delete from pricing"

  CSV.parse(text, headers: true) do |row|
    #print row.fields[0]
    db.execute "insert into pricing values ( ?, ?, ?, ?, ?, ?, ?, ?)", row.fields # equivalent to: [row['name'], row['age']]
  end



#NEW CODe
  db.commit
rescue SQLite3::Exception=> e
  puts "Exception occured"
  puts e
  db.rollback

#ensure
 # db.close if db
end

raise db.execute( "select sku from pricing where idext=20" ).to_s