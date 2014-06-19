require 'mongoid'

class Pedido

  include Mongoid::Document
  store_in collection: "pedidos", database: "dw", session: "default"

  field :sku, type: Integer
  field :cantidad, type: Integer
  field :precio, type: Integer
  field :pedidoId, type: Integer
end
