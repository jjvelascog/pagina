class CreateProductos < ActiveRecord::Migration
  def change
    create_table :productos do |t|
      t.text :sku
      t.text :precio
      t.text :fechaact
      t.text :fechavig
      t.text :costoprod
      t.text :costotras
      t.text :costoalm

      t.timestamps
    end
  end
end
