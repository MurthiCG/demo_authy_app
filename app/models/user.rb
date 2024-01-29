class User < ApplicationRecord
  has_secure_password
  has_one_time_password interval: 60

  attr_accessor :confirm_password, :current_password, :sign_up_process

  validates_presence_of :name, :email
  validates_presence_of :password, if: ->(obj) { obj.sign_up_process }
  validates_uniqueness_of :email, case_sensitive: false
  validates :email, format: { with: /\A[^@\s]+@[^@\s]+\z/ }
  validates :password, length: { in: 8..255, message: "must be between 8 and 255 characters"}, if: ->(obj) { obj.sign_up_process }
  validates :password, format: { with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=|.*[\W])[a-zA-Z\d\W_]*\Z/, message: "must contain at least 1 uppercase letter, 1 lowercase letter, and 1 number." }, if: ->(obj) { obj.sign_up_process }
  validate :validate_confirm_password, if: ->(obj) { obj.confirm_password.present? }

  before_save :set_qr_secret, if: ->(obj) { obj.qr_secret.blank? }

  def sign_in(sign_in_params=[])
    if self.authenticate(sign_in_params[:password])
      status = 200
      if self.authy_enabled?
        self.send_token
        qr_code = self.provisioning_uri(self.name)
        response = { success: true, id: self.id, name: self.name, message: 'An OTP is send to your registered email.', qr_code: qr_code }
      else
        response =  { success: true, id: self.id, name: self.name, token: self.get_access_token}
      end
    else
      response = { success: false, msg: 'Invalid password.' }
      status = 404
    end
    return status, response
  end

  def password_check(password_params = {})
    self.attributes = password_params
    self.valid?
    if self.authenticate(password_params[:password])
      errors.add(:password, "New password cannot be the same as the current password.")
    end
    unless self.authenticate(password_params[:current_password])
      errors.add(:password, "Invalid Password.")
    end
  end

  def send_token
    otp = self.otp_code
    ApplicationMailer.send_otp(self, otp).deliver
  end

  def active?
    confirmed_at.present?
  end

  def get_access_token
    JwtAuth.encode({ id: self.id, email: self.email })
  end

  private

  def validate_confirm_password
    errors.add(:password, "password and confirm password doesn't match") if self.password != self.confirm_password
  end

  def set_qr_secret
    self.qr_secret = self.name
  end

end