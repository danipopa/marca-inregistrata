class CreateCookieConsents < ActiveRecord::Migration[8.1]
  def change
    create_table :cookie_consents do |t|
      t.string :consent_id, null: false
      t.string :version, null: false
      t.boolean :accepted, null: false, default: true
      t.datetime :accepted_at, null: false
      t.string :ip_address
      t.text :user_agent

      t.timestamps
    end

    add_index :cookie_consents, :consent_id, unique: true
    add_index :cookie_consents, :accepted_at
  end
end
