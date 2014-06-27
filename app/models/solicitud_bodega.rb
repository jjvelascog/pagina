require 'mongoid'

class Solicitud_bodega

  include Mongoid::Document
  store_in collection: "solicitudes_bodegas", database: "dw", session: "default"

  field :id_bodega, type: Integer
  field :fecha, type: Date
  field :sku, type: String
  field :cantidad_pedida, type: Integer
  field :cantidad_recibida,type: Integer

end

