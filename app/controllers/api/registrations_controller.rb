# frozen_string_literal: true

module Api
  class RegistrationsController < ApplicationController
    def create
      user = User.new(sign_up_params)
      user.confirm_token = SecureRandom.urlsafe_base64
      user.sign_up_process = true
      if user.save
        ApplicationMailer.send_confirmation_email(user).deliver
        render json: { message: 'Registration completed successfully', success: true }
      else
        render_error(user, :unprocessable_entity)
      end
    end

    def confirm_user
      user = User.find_by(confirm_token: params[:token])
      if user.present?
        user.update_column('confirmed_at', Time.zone.now)
        render json: { success: true, message: 'User Activated successfully.' }
      else
        render json: { success: false, message: "User doesn't exist." }
      end
    end

    private

    def sign_up_params
      params.require(:user).permit(:name, :email, :password, :confirm_password)
    end
  end
end
