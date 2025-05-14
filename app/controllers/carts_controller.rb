# frozen_string_literal: true

class CartsController < ApplicationController
  before_action :find_or_create_cart, only: %i[create]
  before_action :set_cart, only: %i[show add_item remove_product]
  before_action :set_cart_item, only: %i[add_item remove_product]

  def create
    ActiveRecord::Base.transaction do
      product = Product.find(cart_params[:product_id])

      return if check_if_product_is_already_in_the_cart(product)

      @cart_item = CartItem.new(cart: @cart, product: product, quantity: cart_params[:quantity].to_i)

      save_cart_item_and_render(:created)
    end
  rescue ActiveRecord::RecordNotFound
    render_json({ error: 'The product is not found.' }, :not_found)
  rescue StandardError => e
    render_json({ error: e }, :bad_request)
  end

  def show
    render_json(@cart, :ok)
  end

  def add_item
    ActiveRecord::Base.transaction do
      if cart_params[:quantity].to_i < 1
        return render_json({ quantity: ['must be greater than or equal to 1'] }, :unprocessable_entity)
      end

      @cart_item.quantity += cart_params[:quantity].to_i

      save_cart_item_and_render(:ok)
    end
  rescue StandardError => e
    render_json({ error: e }, :bad_request)
  end

  def remove_product
    ActiveRecord::Base.transaction do
      destroy_cart_item_and_render
    end
  rescue StandardError => e
    render_json({ error: e }, :bad_request)
  end

  private

  def set_cart
    @cart = Cart.find(session[:cart_id])
  rescue ActiveRecord::RecordNotFound
    render_json({ error: 'Cart is not found.' }, :not_found)
  end

  def find_or_create_cart
    cart_id = session[:cart_id]

    @cart = Cart.find_or_create_cart(cart_id)

    session[:cart_id] = @cart.id if cart_id.nil?
  rescue ActiveRecord::RecordNotFound
    render_json({ error: 'Cart is not found.' }, :not_found)
  end

  def set_cart_item
    @cart_item = @cart.cart_items.find_by(product_id: cart_params[:product_id])

    render_json({ error: 'The product is not found in the cart.' }, :not_found) unless @cart_item
  end

  def cart_params
    params.permit(:product_id, :quantity)
  end

  def save_cart_item_and_render(status)
    return render_unprocessable_entity(@cart_item.errors) unless @cart_item.save

    @cart.update_total_price(@cart_item.product.price, cart_params[:quantity].to_i, 'increase')

    save_cart_and_render(status)
  end

  def destroy_cart_item_and_render
    return render_unprocessable_entity(@cart_item.errors) unless @cart_item.destroy

    @cart.update_total_price(@cart_item.product.price, @cart_item.quantity, 'discount')

    save_cart_and_render(:ok)
  end

  def save_cart_and_render(status)
    if @cart.save
      render_json(@cart, status)
    else
      render_unprocessable_entity(@cart.errors)
    end
  end

  def render_unprocessable_entity(errors)
    render_json(errors, :unprocessable_entity)
  end

  def check_if_product_is_already_in_the_cart(product)
    return false unless @cart.cart_items.find_by(product: product)

    msg = 'The product is already in the cart. To update item, use route POST /cart/add_item.'
    render_unprocessable_entity({ error: msg })
    true
  end

  def render_json(data, status)
    render json: data, status: status
  end
end
