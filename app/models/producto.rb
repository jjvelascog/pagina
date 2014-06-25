class Producto < ActiveRecord::Base

	def self.actualizar
		#require "sqlite3"
	    require 'csv'
	    require 'date'
	    
	    filepath = "#{Rails.root}/pricing/Pricing.csv"
	    text=File.open(filepath).read


	    Producto.transaction do

	      Producto.delete_all

	      CSV.parse(text, headers: true) do |row|

	        f_vig= Date.strptime(row[4].strip, "%m/%d/%Y")
	        #No agrego los precios productos que no están vigente:
	        #break if f_vig < DateTime.now.strftime('%m/%d/%Y')
	        f_act= Date.strptime(row[3].strip, "%m/%d/%Y")

	        Producto.create!(:sku => row[1].to_i, :precio => row[2].to_i, :fechaact => f_act, :fechavig => f_vig, :costoprod => row[5].to_i, :costotras => row[6].to_i, :costoalm => row[7].to_i)
	      end
	    end
	    #redirect_to(all_productos_path)
	end

	def self.leeraccess
		Dir.chdir ("#{Rails.root}/pricing/")
		system("/usr/lib/jvm/java-7-oracle/jre/bin/java -jar access2csv.jar ~/Dropbox/Grupo4/DBPrecios.accdb")
	end

	def self.get_costo(sku)
		#saca el costo del producto con la última fecha de vigencia, pero no asegura si es o no vigente
		#el parámetro sku es string
		costo_s=Producto.where(sku: sku).order(:fechavig).last[:costoprod]
		costo=costo_s.to_i

		if(costo<0)
			costo=0
		end

		return costo
	end









end
