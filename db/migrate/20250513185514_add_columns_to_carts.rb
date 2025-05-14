# frozen_string_literal: true

class AddColumnsToCarts < ActiveRecord::Migration[7.1]
  def change
    change_table :carts, bulk: true do |t|
      t.datetime :last_interaction_at, default: -> { 'CURRENT_TIMESTAMP' }
      t.integer :status, default: 1, null: false
    end
  end
end
