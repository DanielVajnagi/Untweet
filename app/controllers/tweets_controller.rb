class TweetsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show, :load_more ]
  before_action :set_tweet, only: [ :show, :edit, :update, :destroy, :retweet, :new_quote, :create_quote ]

  # GET /tweets
  def index
    @tweets = Tweet.includes(
      :user,
      :likes,
      :comments,
      :origin,
      origin: [
        :user,
        :likes,
        :comments,
        :retweets,
        retweets: [ :user, :likes, :comments ]
      ],
      retweets: [ :user, :likes, :comments ],
      likes: :user,
      comments: :user
    ).order(created_at: :desc)
     .limit(20)

    @tweet = Tweet.new
  end

  # GET /tweets/1
  def show
    @tweet = Tweet.includes(
      :user,
      :likes,
      :comments,
      :origin,
      origin: [
        :user,
        :likes,
        :comments,
        :retweets,
        retweets: [ :user, :likes, :comments ]
      ],
      retweets: [ :user, :likes, :comments ],
      likes: :user,
      comments: :user
    ).find(params[:id])
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
    # If we're retweeting a retweet, get the original tweet
    original_tweet = @tweet.is_retweet? ? @tweet.original_tweet : @tweet
    @retweet = current_user.tweets.build(origin: original_tweet)

    if @retweet.save
      # Reload the original tweet with all necessary associations
      original_tweet.reload
      broadcast_retweet_update
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              "tweet_#{original_tweet.id}_retweet_count",
              partial: "tweets/retweet_count",
              locals: { tweet: original_tweet }
            ),
            turbo_stream.prepend(
              "tweet_list",
              partial: "tweets/tweet",
              locals: { tweet: @retweet }
            )
          ]
        end
        format.html { redirect_to tweets_path, notice: "Tweet retweeted successfully." }
        format.json { render json: { status: "success", retweet_count: original_tweet.retweet_count } }
      end
    else
      respond_to do |format|
        format.html { redirect_to tweets_path, alert: "Unable to retweet." }
        format.json { render json: { status: "error", message: "Unable to retweet" }, status: :unprocessable_entity }
      end
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
    @original = Tweet.includes(
      :user,
      :likes,
      :comments,
      :origin,
      origin: [
        :user,
        :likes,
        :comments,
        :retweets,
        retweets: [ :user, :likes, :comments ]
      ],
      retweets: [ :user, :likes, :comments ],
      likes: :user,
      comments: :user
    ).find(params[:id])

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

  def load_more
    last_created_at = params[:last_created_at]
    username = params[:username]

    @tweets = Tweet.includes(
      :user,
      :likes,
      :comments,
      :origin,
      origin: [
        :user,
        :likes,
        :comments,
        :retweets,
        retweets: [ :user, :likes, :comments ]
      ],
      retweets: [ :user, :likes, :comments ],
      likes: :user,
      comments: :user
    )

    # If username is provided, filter tweets for that user
    if username.present?
      @tweets = @tweets.where(user: User.find_by!(username: username))
    end

    @tweets = @tweets.where("created_at < ?", last_created_at)
                    .order(created_at: :desc)
                    .limit(20)

    respond_to do |format|
      format.turbo_stream
    end
  end

  private
  def set_tweet
    @tweet = Tweet.find(params[:id])
  end

  def tweet_params
    params.require(:tweet).permit(:body, :origin_id)
  end

  def broadcast_retweet_update
    target_tweet = @tweet.is_retweet? ? @tweet.original_tweet : @tweet

    # Broadcast to the original tweet
    Turbo::StreamsChannel.broadcast_replace_to(
      "tweets",
      target: "tweet_#{target_tweet.id}_retweet_count",
      partial: "tweets/retweet_count",
      locals: { tweet: target_tweet }
    )

    # Broadcast to all retweets of this tweet
    target_tweet.retweets.each do |retweet|
      Turbo::StreamsChannel.broadcast_replace_to(
        "tweets",
        target: "tweet_#{retweet.id}_retweet_count",
        partial: "tweets/retweet_count",
        locals: { tweet: retweet }
      )
    end
  end
end
