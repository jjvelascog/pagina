require 'mongoid'

class ProductoOcupado

  include Mongoid::Document
  store_in collection: "producto_ocupados", database: "dw", session: "default"

  field :sku, type: Integer
  field :cantidad_pedida, type: Integer
  field :cantidad_despachada, type: Integer
  field :ingreso, type: Integer
  field :costo, type: Integer
  
  embedded_in :pedido_cliente
end