class UserMailer < ApplicationMailer

  def account_activation(user, activation_token)
    @user = user
    @activation_token = activation_token
    mail to: user.email, subject: "Account activation"
  end

  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Password reset"
  end
end
