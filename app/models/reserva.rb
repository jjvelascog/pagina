class Reserva < ActiveRecord::Base
	validates_presence_of :sku
	validates_presence_of :cantidad
	validates_presence_of :cliente
	validates_presence_of :fecha
	
	def self.actualizar
		require 'welcome.rb'

		session = GoogleDrive.login("central.ahorro.4@gmail.com","Grupaso4")
	  	ws = session.spreadsheet_by_key("0As9H3pQDLg79dGdkNFlvaUJKa2NjVmllN05VOXhiNmc").worksheets[0]
	  	
	  	#Reserva.delete_all
	  	#fecha = ws[2,2]
	  	
	  	fecha= Date.strptime(ws[2,2].strip, "%d/%m/%Y")
	  			
	  	for i in 5..ws.num_rows()
	  	  reserva = Reserva.where(sku: ws[i,1],cliente: ws[i,2],fecha: fecha)
	  	  if(reserva.empty?)
	    		r = Reserva.new
	    		r.sku = ws[i,1]
	    		r.cliente = ws[i,2]
	    		r.cantidad = ws[i,3].to_f - ws[i,4].to_f
	    		r.fecha = fecha
	    		r.save
	    		#TODO Actualizar sku en spree
	  		end
	  	end
	  	
	  	#Borrar viejas
	    now = Date.today
	    seven_days_ago = (now - 7)
	  	Reserva.all.each do |res|
	  	  if (res.fecha < seven_days_ago)
	  	    sku_temp = res.sku
	  	    res.destroy

	  	  end
	  	end

	  	#TODO Actualizar sku en spree
	  	
		puts "\n\n\n\n SPREE ----------------------------"

	  	Reserva.group(:sku).sum(:cantidad).each do |tot|
	  		almacen=Almacen.new()
	  		stock=almacen.get_stock(tot[0].to_s)
	  		stock_ok=stock-tot[1]

	  		puts "----------------------------#{tot[0]}: #{tot[1]}"

	  		Welcome.CambiarStockN(tot[0], stock_ok)
	  	end



	  	#redirect_to(all_reservas_path)

	end
	
	def self.total_reservas(sku)
	  total_reservas= 0
	  reserva = Reserva.where(sku: sku)
      if(!reserva.empty?)
        total_reservas = reserva.sum(:cantidad)
      end
    return total_reservas
	end
	
end
