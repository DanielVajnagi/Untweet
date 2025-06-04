class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tweet

  def create
    @like = current_user.likes.build(tweet: @tweet)

    if @like.save
      broadcast_like_update
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              "tweet_#{@tweet.id}_like_button",
              partial: "tweets/like_button",
              locals: { tweet: @tweet }
            ),
            turbo_stream.replace(
              "tweet_#{@tweet.id}_like_count",
              partial: "tweets/like_count",
              locals: { tweet: @tweet }
            )
          ]
        end
        format.html { redirect_to @tweet, notice: 'Tweet liked successfully.' }
        format.json { render json: { status: 'success', likes_count: @tweet.likes.count } }
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
    @like = current_user.likes.find_by(tweet: @tweet)

    if @like&.destroy
      broadcast_like_update
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              "tweet_#{@tweet.id}_like_button",
              partial: "tweets/like_button",
              locals: { tweet: @tweet }
            ),
            turbo_stream.replace(
              "tweet_#{@tweet.id}_like_count",
              partial: "tweets/like_count",
              locals: { tweet: @tweet }
            )
          ]
        end
        format.html { redirect_to @tweet, notice: 'Tweet unliked successfully.' }
        format.json { render json: { status: 'success', likes_count: @tweet.likes.count } }
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
        format.html { redirect_to @tweet, alert: 'Unable to unlike tweet.' }
        format.json { render json: { status: 'error', message: 'Unable to unlike tweet' }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_tweet
    @tweet = Tweet.find(params[:tweet_id])
  end

  def broadcast_like_update
    target_tweet = @tweet.is_retweet? ? @tweet.original_tweet : @tweet
    Turbo::StreamsChannel.broadcast_replace_to(
      "tweets",
      target: "tweet_#{target_tweet.id}_like_count",
      partial: "tweets/like_count",
      locals: { tweet: target_tweet }
    )
  end
end