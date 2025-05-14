# frozen_string_literal: true

class MarkCartAsAbandonedJob
  include Sidekiq::Job

  queue_as :default

  def perform(*_args)
    mark_carts_as_abandoned
    remove_abandoned_carts
  end

  private

  def mark_carts_as_abandoned
    Cart.search_for_carts_abandoned.each do |cart|
      cart.mark_as_abandoned
      Rails.logger.info "Carrinho #{cart.id} marcado como abandonado."
    end
  end

  def remove_abandoned_carts
    Cart.search_for_carts_to_remove.each do |cart|
      cart.remove_if_abandoned
      Rails.logger.info "Carrinho #{cart.id} abandonado há mais de 7 dias removido."
    end
  end
end
