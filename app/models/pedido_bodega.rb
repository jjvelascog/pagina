require 'mongoid'

class PedidoBodega

  include Mongoid::Document
  store_in collection: "pedidos_bodegas", database: "dw", session: "default"

  field :id_bodega, type: Integer
  field :fecha, type: Date
  field :sku, type: Integer
  field :cantidad, type: Integer
  field :cantidad_recibida, type: Integer
end
