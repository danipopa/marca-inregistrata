module Api
  module V1
    module Admin
      class MonitoringSubscriptionsController < BaseController
        before_action :authenticate_admin!

        def index
          page = params.fetch(:page, 1).to_i.clamp(1, 100_000)
          subscriptions = MonitoringSubscription.includes(:trademark_request).order(created_at: :desc)
          render json: { provider_configured: TrademarkMonitoring::Provider.current.configured?,
            total: subscriptions.count, page: page,
            subscriptions: subscriptions.offset((page - 1) * 50).limit(50).map { |subscription| serialize(subscription) } }
        end

        def show
          subscription = MonitoringSubscription.find(params[:id])
          match_page = params.fetch(:match_page, 1).to_i.clamp(1, 100_000)
          matches = subscription.monitoring_matches.order(first_seen_at: :desc)
          render json: { subscription: serialize(subscription),
            matches_page: match_page, matches_total: matches.count,
            checks: subscription.monitoring_checks.order(started_at: :desc).limit(20).as_json(only: %i[id status provider started_at finished_at results_count new_matches_count error_message]),
            matches: matches.offset((match_page - 1) * 100).limit(100).as_json(only: %i[id external_id name office trademark_status source_url review_status first_seen_at last_seen_at notified_at]) }
        end

        def update
          subscription = MonitoringSubscription.find(params[:id])
          attributes = params.require(:monitoring_subscription).permit(:status, :registration_number, :registration_office, :interval_hours, :notifications_enabled)
          subscription.with_lock do
            tracked_fields = %w[status registration_number registration_office interval_hours notifications_enabled expires_at]
            previous = subscription.attributes.slice(*tracked_fields).to_json
            requested_status = attributes.delete(:status)
            subscription.assign_attributes(attributes)
            if requested_status == "paused" && !%w[active paused].include?(subscription.status)
              return render json: { message: "Only active monitoring can be paused" }, status: :unprocessable_entity
            end
            if requested_status == "active"
              subscription.save!
              subscription.activate!
            else
              if requested_status.present? && !%w[paused cancelled].include?(requested_status)
                return render json: { message: "Invalid status transition" }, status: :unprocessable_entity
              end
              if requested_status.present?
                subscription.status = requested_status
                subscription.next_check_at = nil if requested_status == "cancelled"
              end
              subscription.save!
            end
            subscription.trademark_request.events.create!(admin_user: current_user,
              action: "monitoring_updated", field_name: "monitoring_subscription",
              old_value: previous, new_value: subscription.attributes.slice(*tracked_fields).to_json)
          end
          render json: { subscription: serialize(subscription.reload) }
        rescue ActiveRecord::RecordInvalid => error
          render json: { errors: error.record.errors.to_hash }, status: :unprocessable_entity
        end

        def check
          subscription = MonitoringSubscription.find(params[:id])
          unless subscription.active_now? && TrademarkMonitoring::Provider.current.configured?
            return render json: { message: "Monitoring must be active and a supported API provider configured" }, status: :unprocessable_entity
          end
          subscription.with_lock do
            if subscription.lease_expires_at.present? && subscription.lease_expires_at > Time.current
              return render json: { message: "A check is already running" }, status: :conflict
            end
            # Do not let a manual check bypass a provider's failure/rate-limit backoff.
            if subscription.last_error.present? && subscription.next_check_at.present? && subscription.next_check_at > Time.current
              return render json: { message: "Retry is scheduled after the provider backoff" }, status: :too_many_requests
            end
            subscription.update!(next_check_at: Time.current)
          end
          CheckTrademarkJob.perform_later(subscription.id)
          render json: { message: "Check queued" }, status: :accepted
        end

        private

        def serialize(subscription)
          { id: subscription.id, order_id: subscription.trademark_request_id, mark: subscription.mark,
            email: subscription.email, registration_number: subscription.registration_number,
            registration_office: subscription.registration_office, status: subscription.status,
            display_status: subscription.display_status, interval_hours: subscription.interval_hours,
            notifications_enabled: subscription.notifications_enabled, activated_at: subscription.activated_at,
            expires_at: subscription.expires_at, next_check_at: subscription.next_check_at,
            last_checked_at: subscription.last_checked_at, last_success_at: subscription.last_success_at,
            last_error: subscription.last_error }
        end
      end
    end
  end
end
