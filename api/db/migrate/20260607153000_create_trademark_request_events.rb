class CreateTrademarkRequestEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :trademark_request_events do |t|
      t.references :trademark_request, null: false, foreign_key: true
      t.references :admin_user, foreign_key: { to_table: :users }
      t.string :action, null: false
      t.string :field_name
      t.text :old_value
      t.text :new_value

      t.timestamps
    end

    add_index :trademark_request_events, :action
    add_index :trademark_request_events, :created_at
  end
end
