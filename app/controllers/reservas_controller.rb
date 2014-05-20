require "rubygems"
require "google_drive"
require 'date'

class ReservasController < ApplicationController
  
  def actualizar

  end

  def index
    #@reserva_tuya = Reserva.where(sku: "3548644").where(cliente: "6833961-8").first.cantidad 
    #@total_reservas = Reserva.where(sku: "3548644").sum(:cantidad)
    Reserva.actualizar
  end


end
