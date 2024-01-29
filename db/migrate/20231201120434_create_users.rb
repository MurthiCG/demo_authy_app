# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :confirm_token
      t.datetime :confirmed_at
      t.string :otp_secret_key
      t.boolean :authy_enabled, default: true
      t.string :qr_secret
      t.timestamps
    end
  end
end
