class ItemsController < ApplicationController
	def new
	end

	def create
  	@item = Item.new(item_params)
 	@item.save
  	redirect_to @item

	end

	def show
		@item = Item.find(params[:id])
	end

	def index
		@items = Item.all
	end
 
private
  	def item_params
    	params.require(:item).permit(:sku, :marca)
  	end
end
