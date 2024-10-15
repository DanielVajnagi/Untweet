require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
  let!(:user) { create(:user, password: 'password') }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe 'POST #create' do
    context 'with valid credentials' do
      it 'logs in the user with email' do
        post :create, params: { user: { login: user.email, password: 'password' } }
        expect(response).to redirect_to(root_path)
        expect(controller.current_user).to eq(user)
      end

      it 'logs in the user with username' do
        post :create, params: { user: { login: user.username, password: 'password' } }
        expect(response).to redirect_to(root_path)
        expect(controller.current_user).to eq(user)
      end
    end

    context 'with invalid credentials' do
      it 'fails to log in with incorrect password' do
        post :create, params: { user: { login: user.email, password: 'wrongpassword' } }
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'fails to log in with nonexistent username' do
        post :create, params: { user: { login: 'wrongusername', password: 'password' } }
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'fails to log in with nonexistent email' do
        post :create, params: { user: { login: 'nonexistent@example.com', password: 'password' } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
