module Api
  module V1
    module Admin
      class MonitoringMatchesController < BaseController
        before_action :authenticate_admin!

        def update
          match = MonitoringMatch.find(params[:id])
          match.with_lock do
            previous = match.review_status
            match.update!(params.require(:monitoring_match).permit(:review_status))
            match.monitoring_subscription.trademark_request.events.create!(admin_user: current_user,
              action: "monitoring_match_reviewed", field_name: "monitoring_match_#{match.id}",
              old_value: previous, new_value: match.review_status)
          end
          render json: { match: match.as_json(only: %i[id review_status notified_at]) }
        rescue ActiveRecord::RecordInvalid => error
          render json: { errors: error.record.errors.to_hash }, status: :unprocessable_entity
        end
      end
    end
  end
end
