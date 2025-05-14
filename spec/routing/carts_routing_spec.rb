require "rails_helper"

RSpec.describe CartsController, type: :routing do
  describe 'routes' do
    it 'routes to #show cart' do
      expect(get: '/cart').to route_to('carts#show', format: :json)
    end

    it 'routes to #create cart' do
      expect(post: '/cart').to route_to('carts#create', format: :json)
    end

    it 'routes to #add_item in a cart' do
      expect(post: '/cart/add_item').to route_to('carts#add_item', format: :json)
    end

    it 'routes to #remove_product in a cart' do
      expect(delete: '/cart/1').to route_to(product_id: '1', controller: 'carts', action: 'remove_product', format: :json)
    end
  end
end 
