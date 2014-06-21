require 'mongoid'

class Quebrado

  include Mongoid::Document
  store_in collection: "quebrados", database: "dw", session: "default"

  field :sku, type: Integer
  field :cantidad, type: Integer
  field :pedidoId, type: Integer
  
  embedded_in :pedido_cliente
end
