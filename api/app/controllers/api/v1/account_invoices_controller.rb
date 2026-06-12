module Api
  module V1
    class AccountInvoicesController < BaseController
      before_action :authenticate_user!

      def show
        trademark_request = accessible_account_purchases.find(params[:purchase_id])

        send_data Invoices::TrademarkRequestPdf.generate(trademark_request),
          filename: invoice_filename(trademark_request),
          type: "application/pdf",
          disposition: "attachment"
      end

      private

      def accessible_account_purchases
        TrademarkRequest
          .where("user_id = :user_id OR lower(email) = :email", user_id: current_user.id, email: current_user.email)
      end

      def invoice_filename(trademark_request)
        prefix = trademark_request.payment_method == "transfer" ? "proforma" : "factura"
        "#{prefix}-#{trademark_request.id}.pdf"
      end
    end
  end
end
