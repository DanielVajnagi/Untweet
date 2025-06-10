class TweetIndex < Chewy::Index
  index_scope Tweet.includes(:user)

  field :body
  field :created_at, type: 'date'
  field :updated_at, type: 'date'
  field :user_id, type: 'integer'
  field :origin_id, type: 'integer'
  field :user_name, value: ->(tweet) { tweet.user.username }
  field :user_email, value: ->(tweet) { tweet.user.email }
  field :is_retweet, value: ->(tweet) { tweet.origin_id.present? && tweet.body.nil? }
  field :is_quote, value: ->(tweet) { tweet.origin_id.present? && tweet.body.present? }
  field :is_original, value: ->(tweet) { tweet.origin_id.nil? }
end