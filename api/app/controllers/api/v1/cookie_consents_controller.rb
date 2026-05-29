module Api
  module V1
    class CookieConsentsController < BaseController
      def create
        consent = CookieConsent.find_or_initialize_by(consent_id: consent_params[:consent_id])
        consent.assign_attributes(
          version: consent_params[:version],
          accepted: consent_params.fetch(:accepted, true),
          accepted_at: Time.current,
          ip_address: request.remote_ip,
          user_agent: request.user_agent.to_s
        )

        if consent.save
          render json: {
            consent: {
              consent_id: consent.consent_id,
              version: consent.version,
              accepted: consent.accepted,
              accepted_at: consent.accepted_at.iso8601
            }
          }, status: :created
        else
          render json: { errors: consent.errors.to_hash }, status: :unprocessable_entity
        end
      end

      private

      def consent_params
        params.require(:cookie_consent).permit(:consent_id, :version, :accepted)
      end
    end
  end
end
