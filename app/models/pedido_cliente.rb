require 'mongoid'

class PedidoCliente

  include Mongoid::Document
  store_in collection: "pedidos_clientes", database: "dw", session: "default"

  field :rut, type: String
  field :pedidoId, type: Integer
  field :fecha, type: Date
  field :direccion, type: String
end
