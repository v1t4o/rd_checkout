require 'rails_helper'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  describe '#perform' do
    let(:abandoned_carts) { create_list(:cart, 2, last_interaction_at: 4.hours.ago) }
    let(:to_remove_carts) { create_list(:cart, 3, last_interaction_at: 8.days.ago, status: :abandoned) }

    before do
      allow(Cart).to receive(:search_for_carts_abandoned).and_return(abandoned_carts)
      allow(Cart).to receive(:search_for_carts_to_remove).and_return(to_remove_carts)
      abandoned_carts.each { |cart| allow(cart).to receive(:mark_as_abandoned) }
      to_remove_carts.each { |cart| allow(cart).to receive(:remove_if_abandoned) }
      allow(Rails.logger).to receive(:info)
    end


    it 'calls mark_carts_as_abandoned and remove_abandoned_carts' do
      expect_any_instance_of(MarkCartAsAbandonedJob).to receive(:mark_carts_as_abandoned)
      expect_any_instance_of(MarkCartAsAbandonedJob).to receive(:remove_abandoned_carts)

      described_class.perform_async

      expect(MarkCartAsAbandonedJob).to have_enqueued_sidekiq_job
      Sidekiq::Worker.drain_all
    end

    describe '#mark_carts_as_abandoned' do
      it 'finds abandoned carts' do
        expect(Cart).to receive(:search_for_carts_abandoned).once
        abandoned_carts.each do |cart|
          expect(cart).to receive(:mark_as_abandoned).once
          expect(Rails.logger).to receive(:info).with("Carrinho #{cart.id} marcado como abandonado.").once
        end

        subject.send(:mark_carts_as_abandoned)
      end
    end

    describe '#remove_abandoned_carts' do
      it 'finds carts to remove' do
        expect(Cart).to receive(:search_for_carts_to_remove).once
        to_remove_carts.each do |cart|
          expect(cart).to receive(:remove_if_abandoned).once
          expect(Rails.logger).to receive(:info).with("Carrinho #{cart.id} abandonado há mais de 7 dias removido.").once
        end

        subject.send(:remove_abandoned_carts)
      end
    end
  end
end