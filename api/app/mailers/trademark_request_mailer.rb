class TrademarkRequestMailer < ApplicationMailer
  ORDERS_EMAIL = "contact@inregistrare-marca.com"

  def order_created(trademark_request)
    @trademark_request = trademark_request

    mail(
      to: ENV.fetch("ORDERS_EMAIL", ORDERS_EMAIL),
      reply_to: @trademark_request.email,
      subject: "Comanda noua ##{@trademark_request.id} - #{@trademark_request.mark}"
    )
  end
end
