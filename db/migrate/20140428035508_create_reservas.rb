class CreateReservas < ActiveRecord::Migration
  def change
    create_table :reservas do |t|
      t.integer :sku
      t.integer :cantidad
      t.string :cliente
      t.date :fecha
      t.string :responsable

      t.timestamps
    end
  end
end
