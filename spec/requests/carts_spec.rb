# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CartsController, type: :controller do
  describe 'POST /cart' do
    let(:cart) { create(:cart, total_price: 0.0) }
    let(:product) { create(:product, name: 'Test Product', price: 10.0) }

    context 'when cart_id does not exists' do
      before do
        session[:cart_id] = 2025
      end

      it 'and return a json error message with status not found' do
        post :create, params: { product_id: product.id, quantity: 1 }, as: :json

        response_body = JSON.parse(response.body)
        expect(response_body['error']).to eq('Cart is not found.')
        expect(response).to have_http_status(:not_found)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'when cart session exists' do
      before do
        session[:cart_id] = cart.id
      end

      context 'when the product already is in the cart' do
        before do
          create(:cart_item, cart: cart, product: product, quantity: 1)
          post :create, params: { product_id: product.id, quantity: 1 }, as: :json
        end

        it 'and return a json error message to use another route' do
          post :create, params: { product_id: product.id, quantity: 1 }, as: :json

          response_body = JSON.parse(response.body)
          expect(response_body['error']).to eq(
            'The product is already in the cart. To update item, use route PUT /cart/add_item.'
          )
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including('application/json'))
        end
      end

      context 'when the product is not in the cart' do
        it 'and add new item in the cart with success' do
          post :create, params: { product_id: product.id, quantity: 1 }, as: :json

          response_body = JSON.parse(response.body)
          expect(response_body['id']).to eq(cart.id)
          expect(response_body['products'][0]['quantity']).to eq(1)
          expect(response_body['products'][0]['name']).to eq('Test Product')
          expect(response_body['products'][0]['unit_price']).to eq('10.0')
          expect(response_body['products'][0]['total_price']).to eq('10.0')
          expect(response_body['total_price']).to eq('10.0')
          expect(response).to have_http_status(:created)
          expect(response.content_type).to match(a_string_including('application/json'))
        end

        it 'and return a json error message when product does not exist' do
          post :create, params: { product_id: 36_092, quantity: 1 }, as: :json

          response_body = JSON.parse(response.body)
          expect(response_body['error']).to eq(
            'The product is not found.'
          )
          expect(response).to have_http_status(:not_found)
          expect(response.content_type).to match(a_string_including('application/json'))
        end

        it 'and return a json error message when quantity is less or equal than zero' do
          post :create, params: { product_id: product.id, quantity: 0 }, as: :json

          response_body = JSON.parse(response.body)
          expect(response_body['quantity'][0]).to eq(
            'must be greater than or equal to 1'
          )
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including('application/json'))
        end

        it 'and return a json error message if occurs StandardError' do
          allow_any_instance_of(Cart).to receive(:update_total_price).and_raise(StandardError)

          post :create, params: { product_id: product.id, quantity: 1 }, as: :json

          response_body = JSON.parse(response.body)
          expect(response_body['error']).to eq(
            'StandardError'
          )
          expect(response).to have_http_status(:bad_request)
          expect(response.content_type).to match(a_string_including('application/json'))
        end

        it 'and return a json error message if failed to save cart' do
          allow_any_instance_of(Cart).to receive(:save).and_return(false)

          post :create, params: { product_id: product.id, quantity: 1 }, as: :json

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including('application/json'))
        end

        it 'and return a json error message if failed to save cart_item' do
          allow_any_instance_of(CartItem).to receive(:save).and_return(false)

          post :create, params: { product_id: product.id, quantity: 1 }, as: :json

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including('application/json'))
        end
      end
    end

    context 'when cart session not exists' do
      context 'when create the new cart' do
        let(:last_cart) { Cart.last }

        it 'and add new item in the cart with success' do
          post :create, params: { product_id: product.id, quantity: 1 }, as: :json

          response_body = JSON.parse(response.body)
          expect(response_body['id']).to eq(last_cart.id)
          expect(response_body['products'][0]['quantity']).to eq(1)
          expect(response_body['products'][0]['name']).to eq('Test Product')
          expect(response_body['products'][0]['unit_price']).to eq('10.0')
          expect(response_body['products'][0]['total_price']).to eq('10.0')
          expect(response_body['total_price']).to eq('10.0')
          expect(response).to have_http_status(:created)
          expect(response.content_type).to match(a_string_including('application/json'))
        end

        it 'and return a json error message when product does not exist' do
          post :create, params: { product_id: 36_092, quantity: 1 }, as: :json

          response_body = JSON.parse(response.body)
          expect(response_body['error']).to eq(
            'The product is not found.'
          )
          expect(response).to have_http_status(:not_found)
          expect(response.content_type).to match(a_string_including('application/json'))
        end

        it 'and return a json error message when quantity is less or equal than zero' do
          post :create, params: { product_id: product.id, quantity: 0 }, as: :json

          response_body = JSON.parse(response.body)
          expect(response_body['quantity'][0]).to eq(
            'must be greater than or equal to 1'
          )
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including('application/json'))
        end

        it 'and return a json error message if occurs StandardError' do
          allow_any_instance_of(Cart).to receive(:update_total_price).and_raise(StandardError)

          post :create, params: { product_id: product.id, quantity: 1 }, as: :json

          response_body = JSON.parse(response.body)
          expect(response_body['error']).to eq(
            'StandardError'
          )
          expect(response).to have_http_status(:bad_request)
          expect(response.content_type).to match(a_string_including('application/json'))
        end

        it 'and return a json error message if failed to save cart' do
          allow_any_instance_of(Cart).to receive(:save).and_return(false)

          post :create, params: { product_id: product.id, quantity: 1 }, as: :json

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including('application/json'))
        end

        it 'and return a json error message if failed to save cart_item' do
          allow_any_instance_of(CartItem).to receive(:save).and_return(false)

          post :create, params: { product_id: product.id, quantity: 1 }, as: :json

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including('application/json'))
        end
      end
    end
  end

  describe 'GET /cart' do
    let(:cart) { create(:cart, total_price: 10.0) }
    let(:product) { create(:product, name: 'Test Product', price: 10.0) }
    let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }

    context 'when cart exists' do
      before do
        session[:cart_id] = cart.id
      end

      it 'and return a json with cart information' do
        get :show

        response_body = JSON.parse(response.body)
        expect(response_body['id']).to eq(cart.id)
        expect(response_body['products'][0]['quantity']).to eq(cart_item.quantity)
        expect(response_body['products'][0]['name']).to eq(product.name)
        expect(response_body['products'][0]['unit_price']).to eq(product.price.to_s)
        expect(response_body['products'][0]['total_price']).to eq((product.price * cart_item.quantity).to_s)
        expect(response_body['total_price']).to eq(cart.total_price.to_s)
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'when cart does not exists' do
      it 'and return a json error message with status not found' do
        get :show

        response_body = JSON.parse(response.body)
        expect(response_body['error']).to eq('Cart is not found.')
        expect(response).to have_http_status(:not_found)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'POST /add_item' do
    let(:cart) { create(:cart, total_price: 10.0) }
    let(:product) { create(:product, name: 'Test Product', price: 10.0) }

    context 'when cart exists' do
      before do
        session[:cart_id] = cart.id
        create(:cart_item, cart: cart, product: product, quantity: 1)
      end

      context 'with the product in the cart' do
        it 'and update quantity of item with success' do
          post :add_item, params: { product_id: product.id, quantity: 1 }, as: :json

          response_body = JSON.parse(response.body)
          expect(response_body['id']).to eq(cart.id)
          expect(response_body['products'][0]['quantity']).to eq(2)
          expect(response_body['products'][0]['name']).to eq('Test Product')
          expect(response_body['products'][0]['unit_price']).to eq('10.0')
          expect(response_body['products'][0]['total_price']).to eq('20.0')
          expect(response_body['total_price']).to eq('20.0')
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to match(a_string_including('application/json'))
        end

        it 'and return a json error message when product does not exist' do
          post :add_item, params: { product_id: 36_092, quantity: 1 }, as: :json

          response_body = JSON.parse(response.body)
          expect(response_body['error']).to eq(
            'The product is not found in the cart.'
          )
          expect(response).to have_http_status(:not_found)
          expect(response.content_type).to match(a_string_including('application/json'))
        end

        it 'and return a json error message when quantity is less or equal than zero' do
          post :add_item, params: { product_id: product.id, quantity: 0 }, as: :json

          response_body = JSON.parse(response.body)
          expect(response_body['quantity'][0]).to eq(
            'must be greater than or equal to 1'
          )
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including('application/json'))
        end

        it 'and return a json error message if occurs StandardError' do
          allow_any_instance_of(Cart).to receive(:update_total_price).and_raise(StandardError)

          post :add_item, params: { product_id: product.id, quantity: 1 }, as: :json

          response_body = JSON.parse(response.body)
          expect(response_body['error']).to eq(
            'StandardError'
          )
          expect(response).to have_http_status(:bad_request)
          expect(response.content_type).to match(a_string_including('application/json'))
        end

        it 'and return a json error message if failed to save cart' do
          allow_any_instance_of(Cart).to receive(:save).and_return(false)

          post :add_item, params: { product_id: product.id, quantity: 1 }, as: :json

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including('application/json'))
        end

        it 'and return a json error message if failed to save cart_item' do
          allow_any_instance_of(CartItem).to receive(:save).and_return(false)

          post :add_item, params: { product_id: product.id, quantity: 1 }, as: :json

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including('application/json'))
        end
      end
    end

    context 'when cart does not exists' do
      it 'and return a json error message with status not found' do
        post :add_item, params: { product_id: product.id, quantity: 1 }, as: :json

        response_body = JSON.parse(response.body)
        expect(response_body['error']).to eq('Cart is not found.')
        expect(response).to have_http_status(:not_found)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'DELETE /cart/:product_id' do
    let(:cart) { create(:cart, total_price: 0.0) }
    let(:product) { create(:product, name: 'Test Product', price: 10.0) }

    context 'when cart exists' do
      before do
        session[:cart_id] = cart.id
        create(:cart_item, cart: cart, product: product, quantity: 1)
      end

      it 'and remove product item and update cart total_price' do
        delete :remove_product, params: { product_id: product.id }

        response_body = JSON.parse(response.body)
        expect(response_body['id']).to eq(cart.id)
        expect(response_body['products']).to eq([])
        expect(response_body['total_price']).to eq('0.0')
        expect(response).to have_http_status(:ok)
      end

      it 'and return a json error message when product not found' do
        delete :remove_product, params: { product_id: 36_092 }

        response_body = JSON.parse(response.body)
        expect(response_body['error']).to eq(
          'The product is not found in the cart.'
        )
        expect(response).to have_http_status(:not_found)
        expect(response.content_type).to match(a_string_including('application/json'))
      end

      it 'and return a json error message if occurs StandardError' do
        allow_any_instance_of(Cart).to receive(:update_total_price).and_raise(StandardError)

        delete :remove_product, params: { product_id: product.id }

        response_body = JSON.parse(response.body)
        expect(response_body['error']).to eq(
          'StandardError'
        )
        expect(response).to have_http_status(:bad_request)
        expect(response.content_type).to match(a_string_including('application/json'))
      end

      it 'and return a json error message if failed to save cart' do
        allow_any_instance_of(Cart).to receive(:save).and_return(false)

        delete :remove_product, params: { product_id: product.id }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end

      it 'and return a json error message if failed to destroy cart_item' do
        allow_any_instance_of(CartItem).to receive(:destroy).and_return(false)

        delete :remove_product, params: { product_id: product.id }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'when cart does not exists' do
      it 'and return a json error message with status not found' do
        delete :remove_product, params: { product_id: product.id }

        response_body = JSON.parse(response.body)
        expect(response_body['error']).to eq('Cart is not found.')
        expect(response).to have_http_status(:not_found)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end
end
