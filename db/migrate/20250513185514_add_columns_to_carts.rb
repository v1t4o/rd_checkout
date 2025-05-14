class AddColumnsToCarts < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :last_interaction_at, :datetime, default: -> { 'CURRENT_TIMESTAMP' }
    add_column :carts, :status, :integer, default: 1, null: false
  end
end
