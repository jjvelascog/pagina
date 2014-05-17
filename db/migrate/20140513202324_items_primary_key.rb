class ItemsPrimaryKey < ActiveRecord::Migration
  def self.up
	add_column :items, :sku, :primary_key
	end

	def self.down
	remove_column :items, :id
	remove_column :items, :sku
	end
end
