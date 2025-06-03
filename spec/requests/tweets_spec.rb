require 'rails_helper'

RSpec.describe "TweetsController", type: :request do
  let(:user) { create(:user) }
  let!(:tweet) { create(:tweet, user: user) }
  let(:locale) { I18n.default_locale }

  include_context 'authenticated_user'

  describe "GET #index" do
    let!(:tweets) { create_list(:tweet, 3) }

    before { get "/#{locale}/tweets" }

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
    it "returns http success" do
      get "/#{locale}/tweets/#{tweet.id}"

      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #new" do
    include_context 'authenticated_user'

    it "returns http success" do
      get "/#{locale}/tweets/new"

      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    include_context 'authenticated_user'

    context "with valid parameters" do
      let(:valid_params) { { tweet: { body: "Test tweet" } } }

      it "creates a new tweet" do
        expect { post "/#{locale}/tweets", params: valid_params }.to change(Tweet, :count).by(1)
      end

      it "redirects to tweets index" do
        post "/#{locale}/tweets", params: valid_params

        expect(response).to redirect_to("/#{locale}/tweets")
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { { tweet: { body: "" } } }

      it "does not create a new tweet" do
        expect { post "/#{locale}/tweets", params: invalid_params }.not_to change(Tweet, :count)
      end

      it "re-renders the index template" do
        post "/#{locale}/tweets", params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("form")
      end
    end
  end

  describe "DELETE #destroy" do
    include_context 'authenticated_user'

    it "deletes the tweet" do
      expect { delete "/#{locale}/tweets/#{tweet.id}" }.to change(Tweet, :count).by(-1)
    end

    it "redirects to tweets index" do
      delete "/#{locale}/tweets/#{tweet.id}"

      expect(response).to redirect_to("/#{locale}/tweets")
    end
  end
end
