class CreateBodegasVecinas < ActiveRecord::Migration
  def change
    create_table :bodegas_vecinas do |t|
      t.string :username
      t.string :password

      t.timestamps
    end
  end
end
