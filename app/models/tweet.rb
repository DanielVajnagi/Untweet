# == Schema Information
#
# Table name: tweets
#
#  id         :bigint           not null, primary key
#  body       :string
#  user_id    :bigint           not null
#  origin_id  :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Tweet < ApplicationRecord
  belongs_to :user
  belongs_to :origin, class_name: "Tweet", optional: true
  has_many :retweets, class_name: "Tweet", foreign_key: :origin_id, dependent: :nullify
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :body, length: { maximum: 280 }, allow_nil: true
  validates :body, presence: true, unless: -> { origin.present? }

  def author?(user)
    self.user == user
  end

  def is_original?
    origin.nil?
  end

  def is_retweet?
    origin.present? && body.nil?
  end

  def is_quote?
    origin.present? && body.present?
  end

  def retweet_count
    # Count direct retweets
    direct_retweets = retweets.count

    # If this is a retweet, add 1 to count this retweet itself
    if is_retweet?
      direct_retweets + 1
    else
      direct_retweets
    end
  end

  def original_tweet
    return self if is_original?

    original = origin
    while original.is_retweet?
      original = original.origin
    end
    original
  end
end
