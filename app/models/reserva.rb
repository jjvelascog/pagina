class Reserva < ActiveRecord::Base
	validates_presence_of :sku
	validates_presence_of :cantidad
	validates_presence_of :cliente
	validates_presence_of :fecha
	validates_presence_of :responsable
end
