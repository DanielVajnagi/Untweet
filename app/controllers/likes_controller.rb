class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tweet

  def create
    # For quotes, we only like the quote itself
    if @tweet.is_quote?
      target_tweet = @tweet
    else
      # For original tweets and retweets, we like the original tweet
      target_tweet = @tweet.is_retweet? ? @tweet.original_tweet : @tweet
    end

    # Create like on target tweet
    @like = current_user.likes.build(tweet: target_tweet)

    if @like.save
      # For original tweets and retweets, create likes on all retweets (excluding quotes)
      unless @tweet.is_quote?
        target_tweet.retweets.where(body: nil).each do |retweet|
          current_user.likes.create(tweet: retweet) unless current_user.likes.exists?(tweet: retweet)
        end
      else
        # For quotes, create likes on all retweets of the quote
        target_tweet.retweets.each do |retweet|
          current_user.likes.create(tweet: retweet) unless current_user.likes.exists?(tweet: retweet)
        end
      end

      broadcast_like_update(target_tweet)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            # Update like button for the clicked tweet
            turbo_stream.replace(
              "tweet_#{@tweet.id}_like_button",
              partial: "tweets/like_button",
              locals: { tweet: @tweet }
            ),
            # Update like count for target tweet
            turbo_stream.replace(
              "tweet_#{target_tweet.id}_like_count",
              partial: "tweets/like_count",
              locals: { tweet: target_tweet }
            ),
            # Update like buttons for all retweets
            *(@tweet.is_quote? ? target_tweet.retweets : target_tweet.retweets.where(body: nil)).map do |retweet|
              turbo_stream.replace(
                "tweet_#{retweet.id}_like_button",
                partial: "tweets/like_button",
                locals: { tweet: retweet }
              )
            end
          ]
        end
        format.html { redirect_to @tweet, notice: "Tweet liked successfully." }
        format.json { render json: { status: "success", likes_count: target_tweet.likes.count } }
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
        format.html { redirect_to @tweet, alert: "Unable to like tweet." }
        format.json { render json: { status: "error", message: "Unable to like tweet" }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    # For quotes, we only unlike the quote itself
    if @tweet.is_quote?
      target_tweet = @tweet
    else
      # For original tweets and retweets, we unlike the original tweet
      target_tweet = @tweet.is_retweet? ? @tweet.original_tweet : @tweet
    end

    # Find and destroy likes on target tweet and all retweets
    tweets_to_unlike = if @tweet.is_quote?
      [ target_tweet, *target_tweet.retweets ]
    else
      [ target_tweet, *target_tweet.retweets.where(body: nil) ]
    end

    current_user.likes.where(tweet: tweets_to_unlike).destroy_all

    broadcast_like_update(target_tweet)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          # Update like button for the clicked tweet
          turbo_stream.replace(
            "tweet_#{@tweet.id}_like_button",
            partial: "tweets/like_button",
            locals: { tweet: @tweet }
          ),
          # Update like count for target tweet
          turbo_stream.replace(
            "tweet_#{target_tweet.id}_like_count",
            partial: "tweets/like_count",
            locals: { tweet: target_tweet }
          ),
          # Update like buttons for all retweets
          *(@tweet.is_quote? ? target_tweet.retweets : target_tweet.retweets.where(body: nil)).map do |retweet|
            turbo_stream.replace(
              "tweet_#{retweet.id}_like_button",
              partial: "tweets/like_button",
              locals: { tweet: retweet }
            )
          end
        ]
      end
      format.html { redirect_to @tweet, notice: "Tweet unliked successfully." }
      format.json { render json: { status: "success", likes_count: target_tweet.likes.count } }
    end
  end

  private

  def set_tweet
    @tweet = Tweet.find(params[:tweet_id])
  end

  def broadcast_like_update(target_tweet)
    # Broadcast to the target tweet
    Turbo::StreamsChannel.broadcast_replace_to(
      "tweets",
      target: "tweet_#{target_tweet.id}_like_count",
      partial: "tweets/like_count",
      locals: { tweet: target_tweet }
    )

    # Broadcast to all retweets of this tweet
    retweets = @tweet.is_quote? ? target_tweet.retweets : target_tweet.retweets.where(body: nil)
    retweets.each do |retweet|
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
