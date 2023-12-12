class Api::UsersController < ApplicationController
  before_action :set_user, only: [:verify_token, :update]
  
  ## Login code
  def sign_in
    user = User.find_by(email: sign_in_params[:email])
    if user.present? and user.active?
      if user.authenticate(sign_in_params[:password])
        if user.authy_enabled?
          user.send_token
          qr_code = user.provisioning_uri(user.name)
          render json: {success: true, id: user.id, name: user.name, message: "An OTP is send to your registered email.", qr_code: qr_code}
        else
          token = JwtAuth.encode({id: user.id, email: user.email})
          render json: {success: true, id: user.id, name: user.name, token: token}
        end
      else
        render json: {success: false, msg: 'Invalid password.'}, status: 404
      end
    elsif user.present? and !user.active?
      render json: {success: false, msg: 'User not Active. please click the confirm button.'}, status: 404
    else
      render json: {success: false, msg: 'User Not Found.'}, status: 404
    end
  end

  def verify_token
    if @user.authenticate_otp(params[:otp])
      token = JwtAuth.encode({id: @user.id, email: @user.email})
      render json: {success: true, message: "Valid OTP",token: token }
    else
      render json: {success: false, message: "Invalid OTP."}
    end
  end

  ## Account settings
  def change_password
    user = current_user
    user.sign_up_process = true
    if user.authenticate(change_password_params[:current_password])
      if user.authenticate(change_password_params[:password])
        render json: {success: false, message: "New password cannot be the same as the current password."}
      else
        if user.update(change_password_params)
          render json: {success: true, message: 'password updated successfully.'}
        else
          render_error(user, :unprocessable_entity)
        end
      end
    else
      render json: {success: false, message: "Invalid Password"}
    end
  end

  def update
    if @user.update(user_params)
      render json: {success: true, message: 'user updated successfully.'}
    else
      render_error(@user, :unprocessable_entity)
    end
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])
    if @user.nil?
      raise ActiveRecord::RecordNotFound                  
    end
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