require "rubygems"

class ProductosController < ApplicationController
  def index

  	require "sqlite3"
    require 'csv'
    require 'Date'

    text=File.open('Pricing.csv').read


    Producto.transaction do

      Producto.destroy_all

      CSV.parse(text, headers: true) do |row|

        f_act= Date.strptime(row[3].strip, "%m/%d/%Y")
        f_vig= Date.strptime(row[4].strip, "%m/%d/%Y")
        #NO AGREGAR LOS QUE NO ESTEN VIGENTES

        Producto.create!(:sku => row[1].to_i, :precio => row[2].to_i, :fechaact => f_act, :fechavig => f_vig, :costoprod => row[5].to_i, :costotras => row[6].to_i, :costoalm => row[7].to_i)
      end
    end


#3raise db.execute( "select sku from pricing where idext=20" ).to_s

  end

end
