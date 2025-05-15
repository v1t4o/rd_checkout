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
      Rails.logger.info I18n.t('job.mark_carts_as_abandoned', id: cart.id)
    end
  end

  def remove_abandoned_carts
    Cart.search_for_carts_to_remove.each do |cart|
      cart.remove_if_abandoned
      Rails.logger.info I18n.t('job.remove_abandoned_carts', id: cart.id)
    end
  end
end
