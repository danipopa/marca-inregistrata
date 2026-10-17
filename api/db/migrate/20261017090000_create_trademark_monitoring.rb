class CreateTrademarkMonitoring < ActiveRecord::Migration[8.1]
  def change
    add_column :trademark_requests, :registration_number, :string
    add_column :trademark_requests, :registration_office, :string

    create_table :monitoring_subscriptions do |t|
      t.references :trademark_request, null: false, foreign_key: true, index: { unique: true }
      t.string :registration_number
      t.string :registration_office
      t.string :status, null: false, default: "pending_activation"
      t.integer :interval_hours, null: false, default: 24
      t.boolean :notifications_enabled, null: false, default: true
      t.datetime :activated_at
      t.datetime :expires_at
      t.datetime :next_check_at
      t.datetime :last_checked_at
      t.datetime :last_success_at
      t.integer :consecutive_failures, null: false, default: 0
      t.string :last_error
      t.string :lease_token
      t.datetime :lease_expires_at
      t.datetime :next_report_at
      t.datetime :last_report_at
      t.timestamps
      t.index [ :status, :next_check_at ]
    end

    create_table :monitoring_checks do |t|
      t.references :monitoring_subscription, null: false, foreign_key: true
      t.string :status, null: false, default: "running"
      t.string :provider, null: false
      t.datetime :started_at, null: false
      t.datetime :finished_at
      t.integer :results_count, null: false, default: 0
      t.integer :new_matches_count, null: false, default: 0
      t.string :error_message
      t.timestamps
    end

    create_table :monitoring_matches do |t|
      t.references :monitoring_subscription, null: false, foreign_key: true
      t.string :identity_key, null: false, limit: 64
      t.string :external_id, null: false
      t.string :name, null: false
      t.string :office, null: false
      t.string :trademark_status
      t.string :application_number
      t.string :registration_number
      t.string :source_url, limit: 2048
      t.string :review_status, null: false, default: "pending"
      t.datetime :first_seen_at, null: false
      t.datetime :last_seen_at, null: false
      t.datetime :notified_at
      t.timestamps
      t.index [ :monitoring_subscription_id, :identity_key ], unique: true, name: "index_monitoring_matches_identity"
    end
  end
end
