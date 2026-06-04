class ContactMessageMailer < ApplicationMailer
  CONTACT_EMAIL = "contact@inregistrare-marca.com"

  def message_created(contact_message)
    @contact_message = contact_message

    mail(
      to: ENV.fetch("CONTACT_EMAIL", CONTACT_EMAIL),
      reply_to: @contact_message.fetch("email"),
      subject: "Mesaj nou de pe inregistrare-marca.com - #{@contact_message.fetch("name")}"
    )
  end
end
