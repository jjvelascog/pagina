require 'mongoid'

class Pedido

  include Mongoid::Document
  store_in collection: "pedidos", database: "dw", session: "default"

  field :sku, type: Integer
  field :cantidad, type: Integer
  field :PedidoId, type: Integer
end
