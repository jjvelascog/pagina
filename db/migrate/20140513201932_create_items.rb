class CreateItems < ActiveRecord::Migration
  def change
    create_table :items, {id: false} do |t|
      t.integer :sku, null: false
      t.string :marca
      t.string :modelo
      t.integer :precio_internet
      t.integer :precio
      t.text :descripcion
      t.string :imagen

      t.timestamps
    end
  end

  def self.primary_key
    'sku'
  end
  
end
