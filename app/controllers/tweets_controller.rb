class TweetsController < ApplicationController
  before_action :authenticate_user!, only: [ :create, :destroy, :retweet, :new_quote, :create_quote ]

  # GET /tweets
  def index
    @tweets = Tweet.all.order(created_at: :desc)
    @tweet = Tweet.new
  end

  # GET /tweets/1
  def show
    @tweet = Tweet.find(params[:id])
  end

  # GET /tweets/new
  def new
    @tweet = Tweet.new
  end

  # GET /tweets/1/edit
  def edit
    @tweet = Tweet.find(params[:id])

    # Only allow editing of original tweets and quoted tweets
    unless @tweet.is_original? || @tweet.is_quote?
      redirect_to tweets_path, alert: t("tweets.not_authorized")
      nil
    end
  end

  # POST /tweets
  def create
    @tweet = Tweet.new(tweet_params)
    @tweet.user = current_user

    # Add impersonation prefix if the tweet is created during impersonation
    if current_user != true_user
      @tweet.body = "[User impersonated] #{@tweet.body}"
    end

    if @tweet.save
      redirect_to tweets_path, notice: t("tweets.created")
    else
      @tweets = Tweet.all.order(created_at: :desc)
      flash.now[:alert] = t("tweets.create_error")
      render :index, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /tweets/1
  def update
    @tweet = Tweet.find(params[:id])

    # Allow updating of original tweets, quoted tweets, and retweets
    unless @tweet.is_original? || @tweet.is_quote? || @tweet.is_retweet?
      redirect_to tweets_path, alert: t("tweets.not_authorized")
      return
    end

    if @tweet.update(tweet_params)
      redirect_to tweets_path, notice: t("tweets.updated")
    else
      flash.now[:alert] = t("tweets.update_error")
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /tweets/1
  def destroy
    @tweet = Tweet.find(params[:id])

    # Only allow deletion of original tweets
    unless @tweet.is_original?
      redirect_to tweets_path, alert: t("tweets.not_authorized")
      return
    end

    if @tweet.user == current_user && @tweet.destroy
      redirect_to tweets_path, notice: t("tweets.deleted")
    end
  end

  # POST /tweets/:id/retweet
  def retweet
    tweet_to_retweet = Tweet.find(params[:id])

    # Find the original tweet to retweet
    original_tweet = tweet_to_retweet.original_tweet

    # Create a new retweet of the original tweet
    retweet = current_user.tweets.build(origin: original_tweet)

    if retweet.save
      redirect_to tweets_path, notice: t("tweets.retweeted")
    else
      redirect_to tweets_path, alert: t("tweets.retweet_error")
    end
  end

  # GET /tweets/:id/new_quote
  def new_quote
    @original = Tweet.find(params[:id])

    # Get the original tweet if this is a retweet
    @original = @original.original_tweet if @original.is_retweet?

    @tweet = current_user.tweets.build(origin: @original)
    render :new
  end

  # POST /tweets/:id/create_quote
  def create_quote
    @original = Tweet.find(params[:id])

    # Get the original tweet if this is a retweet
    @original = @original.original_tweet if @original.is_retweet?

    @tweet = current_user.tweets.build(tweet_params)
    @tweet.origin = @original
    @tweet.user = current_user

    # Add impersonation prefix if the quote is created during impersonation
    if current_user != true_user
      @tweet.body = "[User impersonated] #{@tweet.body}"
    end

    if @tweet.save
      redirect_to tweets_path, notice: t("tweets.quoted")
    else
      # Add a specific error if none are present
      if @tweet.errors.empty?
        @tweet.errors.add(:base, t("tweets.quote_error"))
      end

      flash.now[:alert] = t("tweets.quote_error")
      render :new, status: :unprocessable_entity
    end
  end

  private
  def set_tweet
    @tweet = Tweet.find(params[:id])
  end

  def tweet_params
    params.require(:tweet).permit(:body, :origin_id)
  end
end
