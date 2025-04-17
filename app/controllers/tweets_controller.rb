class TweetsController < ApplicationController
  before_action :authenticate_user!, only: [ :create, :destroy, :retweet, :new_quote, :create_quote ]

  # GET /tweets
  def index
    @tweets = Tweet.all.order(created_at: :desc)
    @tweet = Tweet.new
  end

  # GET /tweets/1
  def show
  end

  # GET /tweets/new
  def new
    @tweet = Tweet.new
  end

  # GET /tweets/1/edit
  def edit
    @tweet = Tweet.find(params[:id])
  end

  # POST /tweets
  def create
    @tweet = Tweet.new(tweet_params)
    @tweet.user = current_user

    if @tweet.save
      redirect_to tweets_path, notice: "Tweet was successfully created."
    else
      @tweets = Tweet.all
      render :index
    end
  end

  # PATCH/PUT /tweets/1
  def update
    @tweet = Tweet.find(params[:id])

    if @tweet.update(tweet_params)
      redirect_to root_path, notice: "Tweet was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /tweets/1
  def destroy
    @tweet = Tweet.find(params[:id])

    if @tweet.user == current_user && @tweet.destroy
      redirect_to tweets_path, notice: "Tweet was successfully deleted."
    end
  end

  # POST /tweets/:id/retweet
  def retweet
    original = Tweet.find(params[:id])

    retweet = current_user.tweets.build(origin: original)

    if retweet.save
      redirect_to tweets_path, notice: "Retweeted!"
    else
      redirect_to tweets_path, alert: "Retweet failed."
    end
  end

  # GET /tweets/:id/new_quote
  def new_quote
    @original = Tweet.find(params[:id])
    @tweet = current_user.tweets.build(origin: @original)
    render :new
  end

  # POST /tweets/:id/create_quote
  def create_quote
    @original = Tweet.find(params[:id])
    @tweet = current_user.tweets.build(tweet_params)
    @tweet.origin = @original

    if @tweet.save
      redirect_to tweets_path, notice: "Quote tweet posted!"
    else
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
