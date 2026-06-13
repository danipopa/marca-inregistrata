class UserMailer < ApplicationMailer
  def password_reset(user, token)
    @user = user
    @reset_url = "#{frontend_url}/password-reset?token=#{ERB::Util.url_encode(token)}"

    mail(
      to: @user.email,
      subject: "Reset your password"
    )
  end

  private

  def frontend_url
    ENV.fetch("FRONTEND_URL", "http://localhost:3000").chomp("/")
  end
end
