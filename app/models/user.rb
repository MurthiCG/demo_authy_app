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

  def send_token
    otp = self.otp_code
    ApplicationMailer.send_otp(self, otp).deliver
  end

  def active?
    confirmed_at.present?
  end

  private

  def validate_confirm_password
    errors.add(:password, "password and confirm password doesn't match") if self.password != self.confirm_password
  end

  def set_qr_secret
    self.qr_secret = self.name
  end

end