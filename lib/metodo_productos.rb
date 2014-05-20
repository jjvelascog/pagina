require "rubygems"

class Metodo_productos
  def self.actualizar

    require "sqlite3"
    require 'csv'
    require 'date'
    
    filepath = "#{Rails.root}/pricing/Pricing.csv"
    text=File.open(filepath).read


    Producto.transaction do

      Producto.destroy_all

      CSV.parse(text, headers: true) do |row|

        f_vig= Date.strptime(row[4].strip, "%m/%d/%Y")
        #No agrego los precios productos que no están vigente:
        #break if f_vig < DateTime.now.strftime('%m/%d/%Y')
        f_act= Date.strptime(row[3].strip, "%m/%d/%Y")

        Producto.create!(:sku => row[1].to_i, :precio => row[2].to_i, :fechaact => f_act, :fechavig => f_vig, :costoprod => row[5].to_i, :costotras => row[6].to_i, :costoalm => row[7].to_i)
      end
    end
  end
end