class RegistrationsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      ConfirmationMailer.confirmation_instructions(@user).deliver_later
      redirect_to root_path, notice: "Confirmation email sent!"
    else
      render :new
    end
  end

  def confirm
    @user = User.find_by(confirmation_token: params[:token])

    if @user&.confirmation_period_valid?
      @user.confirm!
      redirect_to root_path, notice: "Email confirmed!"
    else
      redirect_to root_path, alert: "Invalid or expired confirmation link"
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end
end
