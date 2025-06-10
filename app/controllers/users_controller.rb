class UsersController < ApplicationController
  before_action :set_user, only: [ :show ]

  def show
    @tweets = @user.tweets.includes(
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
  end

  private

  def set_user
    @user = User.find_by!(username: params[:username])
  end
end
