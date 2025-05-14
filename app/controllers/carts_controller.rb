class CartsController < ApplicationController
  before_action :find_or_create_cart, only: %i[ create ]
  before_action :set_cart, only: %i[ show add_item remove_product ]
  before_action :set_cart_item, only: %i[add_item remove_product]

  def create
    ActiveRecord::Base.transaction do
      product = Product.find(cart_params[:product_id])

      if @cart.cart_items.find_by(product: product)
        return render json: {error: "The product is already in the cart. To update item, use route PUT /cart/add_item."}, status: :unprocessable_entity
      end

      cart_item = CartItem.new(cart: @cart, product: product, quantity: cart_params[:quantity].to_i)

      @cart.update_total_price(product.price, cart_params[:quantity].to_i, 'increase')

      if cart_item.save
        if @cart.save
          render json: @cart, status: :created
        else
          render json: @cart.errors, status: :unprocessable_entity
        end
      else
        render json: cart_item.errors, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: "The product is not found." }, status: :not_found
  rescue StandardError => e
    render json: { error: e }, status: :bad_request
  end

  def show
    render json: @cart, status: :ok
  end

  def add_item
    ActiveRecord::Base.transaction do
      if cart_params[:quantity].to_i < 1
        return render json: { quantity: ["must be greater than or equal to 1"] }, status: :unprocessable_entity
      end

      @cart_item.quantity += cart_params[:quantity].to_i

      @cart.update_total_price(@cart_item.product.price, cart_params[:quantity].to_i, 'increase')

      if @cart_item.save
        if @cart.save
          render json: @cart, status: :ok
        else
          render json: @cart.errors, status: :unprocessable_entity
        end
      else
        render json: @cart_item.errors, status: :unprocessable_entity
      end
    end
  rescue StandardError => e
    render json: { error: e }, status: :bad_request
  end

  def remove_product
    ActiveRecord::Base.transaction do
      @cart.update_total_price(@cart_item.product.price, @cart_item.quantity, 'discount')

      if @cart_item.destroy
        if @cart.save
          render json: @cart, status: :ok
        else
          render json: @cart.errors, status: :unprocessable_entity
        end
      else
        render json: @cart_item.errors, status: :unprocessable_entity
      end
    end
  rescue StandardError => e
    render json: { error: e }, status: :bad_request
  end

  private

  def set_cart
    @cart = Cart.find(session[:cart_id])
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: "Cart is not found." }, status: :not_found
  end

  def find_or_create_cart
    cart_id = session[:cart_id]

    @cart = Cart.find_or_create_cart(cart_id)

    session[:cart_id] = @cart.id if cart_id.nil?
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: "Cart is not found." }, status: :not_found
  end

  def set_cart_item
    @cart_item = @cart.cart_items.find_by(product_id: cart_params[:product_id])

    return render json: {error: "The product is not found in the cart."}, status: :not_found unless @cart_item
  end

  def cart_params
    params.permit(:product_id, :quantity)
  end
end
