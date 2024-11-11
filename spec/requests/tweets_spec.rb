require 'rails_helper'

RSpec.describe "TweetsController", type: :request do
  let(:user) { create(:user) }
  let(:tweet) { create(:tweet, user: user) }

  shared_context 'authenticated_user' do
    before do
      sign_in user
    end
  end

  shared_context 'with_tweet' do
    let!(:tweet) { create(:tweet, user: user) }
  end

  describe "GET #index" do
  let!(:tweets) { create_list(:tweet, 3) }

    before { get tweets_path }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "assigns @tweets" do
      expect(response.body).to include(tweets.first.body)
      expect(response.body).to include(tweets.second.body)
      expect(response.body).to include(tweets.third.body)
    end
  end

  describe "GET #show" do
    include_context 'with_tweet'

    it "returns http success" do
      get tweet_path(tweet.id), headers: { "ACCEPT" => "application/json" }
      
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #new" do
    include_context 'authenticated_user'

    it "returns http success" do
      get new_tweet_path, headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    include_context 'authenticated_user'

    context "with valid parameters" do
      let(:valid_params) { { tweet: { body: "Test tweet" } } }

      it "creates a new tweet" do
        expect { post tweets_path, params: valid_params }.to change(Tweet, :count).by(1)
      end

      it "redirects to tweets index" do
        post tweets_path, params: valid_params

        expect(response).to redirect_to(tweets_path)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { { tweet: { body: "" } } }

      it "does not create a new tweet" do
        expect { post tweets_path, params: invalid_params }.not_to change(Tweet, :count)
      end

      it "re-renders the index template" do
        post tweets_path, params: invalid_params

        expect(response.body).to include("form")
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "DELETE #destroy" do
    include_context 'authenticated_user'
    include_context 'with_tweet'

    it "deletes the tweet" do
      expect { delete tweet_path(tweet) }.to change(Tweet, :count).by(-1)
    end

    it "redirects to tweets index" do
      delete tweet_path(tweet)
      
      expect(response).to redirect_to(tweets_path)
    end
  end
end
