module Api
  module V1
    module Admin
      class InvoicesController < BaseController
        before_action :authenticate_admin!

        def show
          trademark_request = TrademarkRequest.find(params[:trademark_request_id])

          send_data Invoices::TrademarkRequestPdf.generate(trademark_request),
            filename: invoice_filename(trademark_request),
            type: "application/pdf",
            disposition: "attachment"
        end

        private

        def invoice_filename(trademark_request)
          prefix = trademark_request.payment_method == "transfer" ? "proforma" : "factura"
          "#{prefix}-#{trademark_request.id}.pdf"
        end
      end
    end
  end
end
