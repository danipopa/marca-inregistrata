require "uri"

module Api
  module V1
    class TrafficPageViewsController < BaseController
      def create
        input = params.require(:page_view).permit(:consent_id, :session_id, :path, :referrer)
        consent = CookieConsent.find_by(consent_id: input[:consent_id], accepted: true, version: TrafficPageView::CONSENT_VERSION)
        return head :forbidden unless consent
        return head :unprocessable_entity unless input[:session_id].to_s.match?(/\A[a-zA-Z0-9-]{16,80}\z/)
        return head :unprocessable_entity unless TrafficPageView::PATHS.include?(input[:path])
        return head :no_content if request.user_agent.to_s.match?(/bot|crawler|spider|headless/i)

        visitor_key = TrafficPageView.anonymous_key(consent.consent_id)
        if TrafficPageView.where(visitor_key: visitor_key, created_at: 1.hour.ago..).count >= 120
          return head :too_many_requests
        end

        TrafficPageView.create!(
          visitor_key: visitor_key,
          session_key: TrafficPageView.anonymous_key("#{consent.consent_id}:#{input[:session_id]}"),
          path: input[:path], referrer_host: referrer_host(input[:referrer])
        )
        head :no_content
      end

      private

      def referrer_host(value)
        return if value.to_s.bytesize > 2048
        uri = URI.parse(value.to_s)
        return unless %w[http https].include?(uri.scheme)
        uri.host&.downcase&.first(255)
      rescue URI::InvalidURIError
        nil
      end
    end
  end
end
