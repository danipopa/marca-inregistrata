module Api
  module V1
    class ContactMessagesController < BaseController
      def create
        contact_message = contact_message_params.to_h

        unless valid_contact_message?(contact_message)
          return render json: {
            message: "Completeaza numele, emailul si mesajul.",
            errors: { contact_message: ["is incomplete"] }
          }, status: :unprocessable_entity
        end

        ContactMessageMailer.message_created(contact_message.merge(ip_address: request.remote_ip)).deliver_now

        render json: { message: "Mesajul a fost trimis." }, status: :created
      end

      private

      def contact_message_params
        params.require(:contact_message).permit(:name, :email, :phone, :message)
      end

      def valid_contact_message?(contact_message)
        contact_message["name"].present? &&
          contact_message["message"].present? &&
          contact_message["email"].present? &&
          URI::MailTo::EMAIL_REGEXP.match?(contact_message["email"])
      end
    end
  end
end
