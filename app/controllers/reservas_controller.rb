require "rubygems"
require "google_drive"
require 'date'

class ReservasController < ApplicationController
  
  def actualizar
    Reserva.actualizar
    redirect_to(all_reservas_path)
  end

  def index
    #@reserva_tuya = Reserva.where(sku: "3548644").where(cliente: "6833961-8").first.cantidad 
    #@total_reservas = Reserva.where(sku: "3548644").sum(:cantidad)
  end


end
