require 'rails_helper'

RSpec.describe TweetsController, type: :controller do
  let(:user) { create(:user) }
  let(:tweet) { create(:tweet, user: user) }

  describe 'GET #index' do
    before do
      sign_in user
      get :index
    end

    it 'assigns @tweets' do
      expect(assigns(:tweets)).to eq(Tweet.order(created_at: :desc))
    end

    it 'assigns a new Tweet to @tweet' do
      expect(assigns(:tweet)).to be_a_new(Tweet)
    end
  end

  describe 'GET #edit' do
    before do
      sign_in user
      get :edit, params: { id: tweet.id }
    end

    it 'assigns the requested tweet to @tweet' do
      expect(assigns(:tweet)).to eq(tweet)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new tweet' do
        sign_in user
        expect {
          post :create, params: { tweet: { body: 'Test tweet' } }
        }.to change(Tweet, :count).by(1)
      end

      it 'redirects to the tweets index' do
        sign_in user
        post :create, params: { tweet: { body: 'Test tweet' } }
        expect(response).to redirect_to(tweets_path)
        expect(flash[:notice]).to eq('Tweet was successfully created.')
      end
    end

    context 'with invalid attributes' do
      it 'does not create a new tweet' do
        sign_in user
        expect {
          post :create, params: { tweet: { body: '' } }
        }.not_to change(Tweet, :count)
      end

      it 'renders the index template' do
        sign_in user
        post :create, params: { tweet: { body: '' } }
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid attributes' do
      it 'updates the tweet' do
        sign_in user
        patch :update, params: { id: tweet.id, tweet: { body: 'Updated tweet' } }
        tweet.reload
        expect(tweet.body).to eq('Updated tweet')
      end

      it 'redirects to the root path' do
        sign_in user
        patch :update, params: { id: tweet.id, tweet: { body: 'Updated tweet' } }
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq('Tweet was successfully updated.')
      end
    end

    context 'with invalid attributes' do
      it 'does not update the tweet' do
        sign_in user
        patch :update, params: { id: tweet.id, tweet: { body: '' } }
        expect(tweet.body).not_to eq('')
      end

      it 'renders the edit template' do
        sign_in user
        patch :update, params: { id: tweet.id, tweet: { body: '' } }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when the user is the owner' do
      it 'deletes the tweet' do
        sign_in user
        tweet # Ensure the tweet is created
        expect {
          delete :destroy, params: { id: tweet.id }
        }.to change(Tweet, :count).by(-1)
      end

      it 'redirects to the tweets index' do
        sign_in user
        delete :destroy, params: { id: tweet.id }
        expect(response).to redirect_to(tweets_path)
        expect(flash[:notice]).to eq('Tweet was successfully deleted.')
      end
    end

    context 'when the user is not the owner' do
      let(:another_user) { create(:user) }

      it 'does not delete the tweet' do
        sign_in another_user
        tweet # Ensure the tweet is created
        expect {
          delete :destroy, params: { id: tweet.id }
        }.not_to change(Tweet, :count)
      end
    end
  end
end
