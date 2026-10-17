class CreateTrafficMetrics < ActiveRecord::Migration[8.1]
  def change
    create_table :traffic_page_views do |t|
      t.string :visitor_key, null: false, limit: 64
      t.string :session_key, null: false, limit: 64
      t.string :path, null: false, limit: 100
      t.string :referrer_host, limit: 255
      t.datetime :created_at, null: false
    end
    add_index :traffic_page_views, :created_at
    add_index :traffic_page_views, [ :visitor_key, :created_at ]

    create_table :traffic_request_metrics do |t|
      t.datetime :hour, null: false
      t.string :endpoint, null: false, limit: 180
      t.integer :status, null: false
      t.bigint :requests_count, null: false, default: 0
      t.bigint :duration_ms_total, null: false, default: 0
      t.bigint :duration_ms_max, null: false, default: 0
    end
    add_index :traffic_request_metrics, [ :hour, :endpoint, :status ], unique: true, name: "index_traffic_request_bucket"
  end
end
