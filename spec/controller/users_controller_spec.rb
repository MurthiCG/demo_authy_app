# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::UsersController, type: :controller do
  describe 'POST sign_in' do
    context 'valid user' do
      let(:user) { create(:user, email: 'tester@test.com') }
      let(:params) do
        { user: { email: 'tester@test.com', password: 'Password@123' } }
      end

      it 'with authy enabled' do
        user
        post(:sign_in, params:)
        expect(response.status).to eq(200)
        expect(json(response.body).keys).to include('id')
        expect(json(response.body).keys).to include('name')
        expect(json(response.body).keys).to include('message')
        expect(json(response.body).keys).to include('qr_code')
      end

      it 'without authy enabled' do
        user.update_column('authy_enabled', false)
        post(:sign_in, params:)
        expect(response.status).to eq(200)
        expect(json(response.body).keys).to include('token')
      end
    end

    context 'Invalid user' do
      let(:user) { create(:user, email: 'tester@test.com') }
      let(:params) do
        { user: { email: 'tester@test.com', password: 'Password@1234' } }
      end

      it 'with authy enabled' do
        user
        post(:sign_in, params:)
        expect(response.status).to eq(404)
        expect(json(response.body)).to eq(json({ success: false, msg: 'Invalid password.' }.to_json))
      end
    end

    context 'Not confirm user' do
      let(:user) { create(:user, email: 'tester@test.com', confirmed_at: nil) }
      let(:params) do
        { user: { email: 'tester@test.com', password: 'Password@1234' } }
      end

      it 'with authy enabled' do
        user
        post(:sign_in, params:)
        expect(response.status).to eq(404)
        expect(json(response.body)).to eq(json({ success: false,
                                                 msg: 'User not Active. please click the confirm button.' }.to_json))
      end
    end

    context 'invalid user' do
      let(:user) { create(:user, email: 'tester1@test.com', confirmed_at: nil) }
      let(:params) do
        { user: { email: 'tester@test.com', password: 'Password@1234' } }
      end

      it 'with authy enabled' do
        user
        post(:sign_in, params:)
        expect(response.status).to eq(404)
        expect(json(response.body)).to eq(json({ success: false, msg: 'User Not Found.' }.to_json))
      end
    end
  end

  describe 'PUT verify_token' do
    let(:user) { create(:user, email: 'tester@test.com') }
    it 'valid token' do
      token = user.otp_code
      put :verify_token, params: { id: user.id, otp: token }
      expect(json(response.body).keys).to include('token')
    end

    it 'invalid token' do
      put :verify_token, params: { id: user.id, otp: '11111111' }
      expect(json(response.body).keys).not_to include('token')
      expect(json(response.body)).to eq(json({ success: false, message: 'Invalid OTP.' }.to_json))
    end
  end

  describe 'PUT update' do
    let(:user) { create(:user, email: 'tester@test.com') }
    it 'setting authy_enabled to false' do
      put :update, params: { id: user.id, user: { authy_enabled: 0 } }
      expect(user.reload.authy_enabled).to eq(false)
    end

    it 'setting authy_enabled to true' do
      put :update, params: { id: user.id, user: { authy_enabled: 1 } }
      expect(user.reload.authy_enabled).to eq(true)
    end

    it 'setting qr_code' do
      put :update, params: { id: user.id, user: { authy_enabled: 1, qr_secret: 'Dummy' } }
      expect(user.reload.qr_secret).to eq('Dummy')
    end
  end

  describe 'PUT change_password' do
    let(:user) { create(:user, email: 'tester@test.com') }
    let(:token) { JwtAuth.encode({ id: user.id, email: user.email }) }

    it 'invalid current password' do
      request.headers.merge!({ 'Authorization' => token })
      put :change_password, params: { id: user.id, user: { current_password: 'Password@1234' } }
      expect(response.status).to eq(422)
    end

    it 'password and current password are same' do
      request.headers.merge!({ 'Authorization' => token })
      put :change_password,
          params: { id: user.id, user: { current_password: 'Password@123', password: 'Password@123' } }
      expect(json(response.body)).to eq(json({ password: ["New password cannot be the same as the current password."] }.to_json))
    end

    it "password and confirm password doesn't match" do
      request.headers.merge!({ 'Authorization' => token })
      put :change_password,
          params: { id: user.id,
                    user: { current_password: 'Password@123', password: 'Password@1234',
                            confirm_password: 'Password@12345' } }
      expect(json(response.body)).to eq(json({ password: ["password and confirm password doesn't match"] }.to_json))
    end

    it 'password length and alphanueric check' do
      request.headers.merge!({ 'Authorization' => token })
      put :change_password,
          params: { id: user.id,
                    user: { current_password: 'Password@123', password: 'Pass', confirm_password: 'Pass' } }
      expect(json(response.body)['password'].count).to eq(2)
    end

    it 'successful update' do
      request.headers.merge!({ 'Authorization' => token })
      put :change_password,
          params: { id: user.id,
                    user: { current_password: 'Password@123', password: 'Password@1234',
                            confirm_password: 'Password@1234' } }
      expect(json(response.body)).to eq(json({ success: true, message: 'password updated successfully.' }.to_json))
    end
  end
end
