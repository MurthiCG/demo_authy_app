require 'spec_helper'
require 'rails_helper'

RSpec.describe User, type: :model do
  describe "User" do
    context "secure password" do
      it { should have_secure_password }
    end

  	context "Validation" do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_presence_of(:email) }
      it { is_expected.to validate_presence_of(:password) }

  	  it { should allow_value("demo@domain.com").for(:email) }
  	  it { should_not allow_value("demo").for(:email) }

  	  it { should allow_value("Tester@123").for(:password) }
  	end

  	context "methods" do
  	  let(:user) {create(:user)}
      it "set_qr_secret" do 
        expect(user.qr_secret).to eq(user.name)
      end

  	  it "active?" do
  	  	expect(user.confirmed_at).to be_within(2.days).of(Time.current)
  	  	expect(user.confirmed_at).not_to eql(nil)
  	  end
  	end
  end

end