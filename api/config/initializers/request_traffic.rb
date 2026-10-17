require Rails.root.join("app/middleware/request_traffic")
Rails.application.config.middleware.use RequestTraffic
