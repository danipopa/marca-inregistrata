class RequestTraffic
  def initialize(app)
    @app = app
  end

  def call(env)
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    status = 500
    response = @app.call(env)
    status = response[0]
    response
  ensure
    record(env, status, started)
  end

  private

  def record(env, status, started)
    path = env["PATH_INFO"].to_s
    return unless path.start_with?("/api/")
    return if path == "/api/v1/traffic_page_views" || path == "/api/v1/admin/traffic"
    return if env["REQUEST_METHOD"] == "OPTIONS"

    route = env["action_dispatch.request.path_parameters"] || {}
    endpoint = if route[:controller].present? && route[:action].present?
      "#{env['REQUEST_METHOD']} #{route[:controller]}##{route[:action]}"
    else
      "#{env['REQUEST_METHOD']} (unmatched)"
    end
    duration = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000).round
    TrafficRequestMetric.record!(endpoint: endpoint.first(180), status: status.to_i, duration_ms: duration)
  rescue StandardError => error
    # Observability must never prevent serving the original response or expose request data.
    Rails.logger.warn("traffic_metrics_write_failed error=#{error.class}")
  end
end
