# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  describe '#perform' do
    let(:abandoned_carts) { create_list(:cart, 2, last_interaction_at: 4.hours.ago) }
    let(:to_remove_carts) { create_list(:cart, 3, last_interaction_at: 8.days.ago, status: :abandoned) }

    before do
      allow(Cart).to receive_messages(search_for_carts_abandoned: abandoned_carts,
                                      search_for_carts_to_remove: to_remove_carts)
      abandoned_carts.each { |cart| allow(cart).to receive(:mark_as_abandoned) }
      to_remove_carts.each { |cart| allow(cart).to receive(:remove_if_abandoned) }
      allow(Rails.logger).to receive(:info)
    end

    it 'calls mark_carts_as_abandoned and remove_abandoned_carts' do
      expect_any_instance_of(described_class).to receive(:mark_carts_as_abandoned)
      expect_any_instance_of(described_class).to receive(:remove_abandoned_carts)

      described_class.perform_async

      expect(described_class).to have_enqueued_sidekiq_job
      Sidekiq::Worker.drain_all
    end

    describe '#mark_carts_as_abandoned' do
      it 'finds abandoned carts' do
        subject.send(:mark_carts_as_abandoned)

        expect(Cart).to have_received(:search_for_carts_abandoned).once
      end

      it 'call func to mark cart as abandoned' do
        subject.send(:mark_carts_as_abandoned)

        abandoned_carts.each do |cart|
          expect(cart).to have_received(:mark_as_abandoned).once
        end
      end

      it 'log info when mark cart as abandoned' do
        subject.send(:mark_carts_as_abandoned)

        abandoned_carts.each do |cart|
          expect(Rails.logger).to have_received(:info)
            .with(I18n.t('job.mark_carts_as_abandoned', id: cart.id)).once
        end
      end
    end

    describe '#remove_abandoned_carts' do
      it 'finds carts to remove' do
        subject.send(:remove_abandoned_carts)

        expect(Cart).to have_received(:search_for_carts_to_remove).once
      end

      it 'call func to remove each cart founded' do
        subject.send(:remove_abandoned_carts)

        to_remove_carts.each do |cart|
          expect(cart).to have_received(:remove_if_abandoned).once
        end
      end

      it 'log info when remove each cart founded' do
        subject.send(:remove_abandoned_carts)

        to_remove_carts.each do |cart|
          expect(Rails.logger).to have_received(:info)
            .with(I18n.t('job.remove_abandoned_carts', id: cart.id)).once
        end
      end
    end
  end
end
