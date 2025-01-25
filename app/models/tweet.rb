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
end
