module Api
  module V1
    module Admin
      class TrafficController < BaseController
        before_action :authenticate_admin!

        def show
          days = params[:days].to_i.clamp(1, 90)
          days = 30 if params[:days].blank?
          since = (days - 1).days.ago.beginning_of_day
          views = TrafficPageView.where(created_at: since..)
          metrics = TrafficRequestMetric.where(hour: since..)
          count = metrics.sum(:requests_count)
          daily = views.group(Arel.sql("DATE(created_at)")).count

          render json: {
            days: days, timezone: Time.zone.name,
            visitors: views.distinct.count(:visitor_key), sessions: views.distinct.count(:session_key), page_views: views.count,
            daily: (since.to_date..Date.current).map { |date| { date: date.iso8601, views: daily[date.iso8601] || daily[date] || 0 } },
            pages: views.group(:path).order(Arel.sql("COUNT(*) DESC")).count.map { |path, total| { path: path, views: total } },
            referrers: views.group(:referrer_host).order(Arel.sql("COUNT(*) DESC")).limit(20).count.map { |host, total| { host: host.presence || "Direct / unknown", views: total } },
            technical: {
              requests: count,
              server_errors: metrics.where(status: 500..599).sum(:requests_count),
              client_errors: metrics.where(status: 400..499).sum(:requests_count),
              average_ms: count.zero? ? 0 : (metrics.sum(:duration_ms_total).to_f / count).round(1),
              max_ms: metrics.maximum(:duration_ms_max) || 0,
              endpoints: metrics.group(:endpoint).order(Arel.sql("SUM(requests_count) DESC")).limit(30).sum(:requests_count).map { |endpoint, total| { endpoint: endpoint, requests: total } }
            }
          }
        end
      end
    end
  end
end
