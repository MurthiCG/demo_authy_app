# frozen_string_literal: true

module Api
  class UsersController < ApplicationController
    before_action :set_user, only: %i[verify_token update]

    ## Login code
    def sign_in
      user = User.find_by(email: sign_in_params[:email])
      if user.present? && user.active?
        status, data = user.sign_in(sign_in_params)
        render json: data, status: status
      elsif user.present? && !user.active?
        render json: { success: false, msg: 'User not Active. please click the confirm button.' }, status: 404
      else
        render json: { success: false, msg: 'User Not Found.' }, status: 404
      end
    end

    def verify_token
      if @user.authenticate_otp(params[:otp])
        render json: { success: true, message: 'Valid OTP', token: @user.get_access_token}
      else
        render json: { success: false, message: 'Invalid OTP.' }
      end
    end

    ## Account settings
    def change_password
      user = current_user
      user.sign_up_process = true
      valid_password = user.password_check(change_password_params)
      if valid_password && user.update(change_password_params)
        render json: { success: true, message: 'password updated successfully.' }
      else
        render_error(user, :unprocessable_entity)
      end
    end

    def update
      if @user.update(user_params)
        render json: { success: true, message: 'user updated successfully.' }
      else
        render_error(@user, :unprocessable_entity)
      end
    end

    private

    def set_user
      @user = User.find_by(id: params[:id])
      return unless @user.nil?

      raise ActiveRecord::RecordNotFound
    end

    def sign_in_params
      params.require(:user).permit(:email, :password)
    end

    def change_password_params
      params.require(:user).permit(:password, :current_password, :confirm_password)
    end

    def user_params
      params.require(:user).permit(:name, :authy_enabled, :qr_secret)
    end
  end
end
