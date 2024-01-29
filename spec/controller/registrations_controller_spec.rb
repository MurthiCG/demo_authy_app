# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::RegistrationsController, type: :controller do
  describe 'POST #create' do
    context 'valid form params' do
      let(:params) do
        {
          user: {
            name: Faker::Name.name,
            email: Faker::Internet.email,
            password: 'Password@123',
            confirm_password: 'Password@123'
          }
        }
      end

      it 'creates' do
        expect do
          post :create, params:
        end.to change(User, :count).by(1)
      end

      it 'renders response' do
        post(:create, params:)
        expect(json(response.body)).to eq(json({ message: 'Registration completed successfully',
                                                 success: true }.to_json))
        expect(response.status).to eq(200)
      end
    end

    context 'invalid form params' do
      let(:params) do
        {
          user: {
            name: Faker::Name.name,
            email: Faker::Internet.email,
            password: 'Password@1234',
            confirm_password: 'Password@123'
          }
        }
      end

      it 'creates' do
        expect do
          post :create, params:
        end.to change(User, :count).by(0)
      end

      it 'renders response' do
        post(:create, params:)
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'GET confirm_user' do
    context 'valid token' do
      let(:user) { create(:user) }
      let(:params) { { token: user.confirm_token } }
      let(:invalid_params) { { token: SecureRandom.urlsafe_base64 } }

      it 'confirms user' do
        post(:confirm_user, params:)
        expect(response.status).to eq(200)
        expect(json(response.body)).to eq(json({ success: true, message: 'User Activated successfully.' }.to_json))
      end

      it 'invalid token' do
        post :confirm_user, params: invalid_params
        expect(json(response.body)).to eq(json({ success: false, message: "User doesn't exist." }.to_json))
      end
    end
  end
end
