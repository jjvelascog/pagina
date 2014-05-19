class CreateLastPedidos < ActiveRecord::Migration
  def change
    create_table :last_pedidos do |t|
      t.integer :num

      t.timestamps
    end
  end
end
