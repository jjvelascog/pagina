require "rubygems"
require "google_drive"
require 'date'

class ReservasController < ApplicationController
  
  def actualizar
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
  		end
  	end
  	
  	#Borrar viejas
    now = Date.today
    seven_days_ago = (now - 7)
  	Reserva.all.each do |res|
  	  if (res.fecha < seven_days_ago)
  	    res.destroy
  	    puts "aqui"
  	  end
  	end
  	redirect_to(all_reservas_path)
  end

  def index
    #@reserva_tuya = Reserva.where(sku: "3548644").where(cliente: "6833961-8").first.cantidad 
    #@total_reservas = Reserva.where(sku: "3548644").sum(:cantidad)
  end


end
