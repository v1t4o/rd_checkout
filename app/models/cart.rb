class Cart < ApplicationRecord
  has_many :cart_items
  has_many :products, :through => :cart_items

  enum status: { active: 1, abandoned: 0 }

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  PERIOD_OF_CART_ABANDONED=3.hours.ago
  PERIOD_OF_CARTS_TO_REMOVE=7.days.ago

  def self.find_or_create_cart(cart_id)
    return Cart.find(cart_id) unless cart_id.nil?

    Cart.create!
  end

  def update_total_price(price, quantity, action)
    case action
    when 'increase'
      self.total_price += price * quantity
    when 'discount'
      self.total_price -= price * quantity
      self.total_price = self.total_price.clamp(0, Float::INFINITY)
    end
  end

  def mark_as_abandoned
    self.abandoned!
  end

  def remove_if_abandoned
    if self.abandoned?
      self.delete
    end
  end

  def self.search_for_carts_abandoned
    self.where('last_interaction_at <= ? AND status != ?', PERIOD_OF_CART_ABANDONED, self.statuses[:abandoned])
  end

  def self.search_for_carts_to_remove
    self.where(status: self.statuses[:abandoned]).where('last_interaction_at <= ?', PERIOD_OF_CARTS_TO_REMOVE)
  end
end
