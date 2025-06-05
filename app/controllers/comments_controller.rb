class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tweet
  before_action :set_comment, only: [:destroy]

  def create
    @comment = @tweet.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      broadcast_comment_update
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              "tweet_#{@tweet.id}_comment_count",
              partial: "tweets/comment_count",
              locals: { tweet: @tweet }
            )
          ]
        end
        format.html { redirect_to @tweet, notice: 'Comment added successfully.' }
        format.json { render json: { status: 'success', comment_count: @tweet.comments.count } }
      end
    else
      respond_to do |format|
        format.html { redirect_to @tweet, alert: 'Unable to add comment.' }
        format.json { render json: { status: 'error', message: 'Unable to add comment' }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @comment&.destroy
      broadcast_comment_update
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              "tweet_#{@tweet.id}_comment_count",
              partial: "tweets/comment_count",
              locals: { tweet: @tweet }
            )
          ]
        end
        format.html { redirect_to @tweet, notice: 'Comment removed successfully.' }
        format.json { render json: { status: 'success', comment_count: @tweet.comments.count } }
      end
    else
      respond_to do |format|
        format.html { redirect_to @tweet, alert: 'Unable to remove comment.' }
        format.json { render json: { status: 'error', message: 'Unable to remove comment' }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_tweet
    @tweet = Tweet.find(params[:tweet_id])
  end

  def set_comment
    @comment = @tweet.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end

  def broadcast_comment_update
    target_tweet = @tweet.is_retweet? ? @tweet.original_tweet : @tweet
    Turbo::StreamsChannel.broadcast_replace_to(
      "tweets",
      target: "tweet_#{target_tweet.id}_comment_count",
      partial: "tweets/comment_count",
      locals: { tweet: target_tweet }
    )
  end
end