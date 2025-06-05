class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tweet

  def create
    # If we're liking a retweet, get the original tweet
    original_tweet = @tweet.is_retweet? ? @tweet.original_tweet : @tweet

    # Create like on original tweet
    @like = current_user.likes.build(tweet: original_tweet)

    if @like.save
      # Create likes on all retweets
      original_tweet.retweets.each do |retweet|
        current_user.likes.create(tweet: retweet) unless current_user.likes.exists?(tweet: retweet)
      end

      broadcast_like_update
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            # Update like button for the clicked tweet (retweet or original)
            turbo_stream.replace(
              "tweet_#{@tweet.id}_like_button",
              partial: "tweets/like_button",
              locals: { tweet: @tweet }
            ),
            # Update like count for original tweet
            turbo_stream.replace(
              "tweet_#{original_tweet.id}_like_count",
              partial: "tweets/like_count",
              locals: { tweet: original_tweet }
            ),
            # Update like buttons for all retweets
            *original_tweet.retweets.map do |retweet|
              turbo_stream.replace(
                "tweet_#{retweet.id}_like_button",
                partial: "tweets/like_button",
                locals: { tweet: retweet }
              )
            end
          ]
        end
        format.html { redirect_to @tweet, notice: 'Tweet liked successfully.' }
        format.json { render json: { status: 'success', likes_count: original_tweet.likes.count } }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "tweet_#{@tweet.id}_like_button",
            partial: "tweets/like_button",
            locals: { tweet: @tweet }
          )
        end
        format.html { redirect_to @tweet, alert: 'Unable to like tweet.' }
        format.json { render json: { status: 'error', message: 'Unable to like tweet' }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    # If we're unliking a retweet, get the original tweet
    original_tweet = @tweet.is_retweet? ? @tweet.original_tweet : @tweet

    # Find and destroy likes on original tweet and all retweets
    current_user.likes.where(tweet: [original_tweet, *original_tweet.retweets]).destroy_all

    broadcast_like_update
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          # Update like button for the clicked tweet (retweet or original)
          turbo_stream.replace(
            "tweet_#{@tweet.id}_like_button",
            partial: "tweets/like_button",
            locals: { tweet: @tweet }
          ),
          # Update like count for original tweet
          turbo_stream.replace(
            "tweet_#{original_tweet.id}_like_count",
            partial: "tweets/like_count",
            locals: { tweet: original_tweet }
          ),
          # Update like buttons for all retweets
          *original_tweet.retweets.map do |retweet|
            turbo_stream.replace(
              "tweet_#{retweet.id}_like_button",
              partial: "tweets/like_button",
              locals: { tweet: retweet }
            )
          end
        ]
      end
      format.html { redirect_to @tweet, notice: 'Tweet unliked successfully.' }
      format.json { render json: { status: 'success', likes_count: original_tweet.likes.count } }
    end
  end

  private

  def set_tweet
    @tweet = Tweet.find(params[:tweet_id])
  end

  def broadcast_like_update
    original_tweet = @tweet.is_retweet? ? @tweet.original_tweet : @tweet

    # Broadcast to the original tweet
    Turbo::StreamsChannel.broadcast_replace_to(
      "tweets",
      target: "tweet_#{original_tweet.id}_like_count",
      partial: "tweets/like_count",
      locals: { tweet: original_tweet }
    )

    # Broadcast to all retweets of this tweet
    original_tweet.retweets.each do |retweet|
      # Broadcast like count
      Turbo::StreamsChannel.broadcast_replace_to(
        "tweets",
        target: "tweet_#{retweet.id}_like_count",
        partial: "tweets/like_count",
        locals: { tweet: retweet }
      )
    end
  end
end