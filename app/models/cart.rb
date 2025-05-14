# frozen_string_literal: true

class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  enum status: { active: 1, abandoned: 0 }

  validates :total_price, numericality: { greater_than_or_equal_to: 0 }

  def self.period_of_cart_abandoned
    3.hours.ago
  end

  def self.period_of_carts_to_remove
    7.days.ago
  end

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
    abandoned!
  end

  def remove_if_abandoned
    return unless abandoned?

    delete
  end

  def self.search_for_carts_abandoned
    where('last_interaction_at <= ? AND status != ?', period_of_cart_abandoned, statuses[:abandoned])
  end

  def self.search_for_carts_to_remove
    where(status: statuses[:abandoned]).where('last_interaction_at <= ?', period_of_carts_to_remove)
  end
end
