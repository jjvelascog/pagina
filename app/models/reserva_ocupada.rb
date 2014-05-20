require 'mongoid'

class Reserva_ocupada

  include Mongoid::Document
  store_in collection: "reservas_ocupadas", database: "dw", session: "default"

  field :sku, type: Integer
  field :cantidad, type: Integer
  field :pedidoId, type: Integer
end
