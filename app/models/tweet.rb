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
  has_many :retweets, class_name: "Tweet", foreign_key: "origin_id"
  has_many :likes
  has_many :comments

  validates :body, length: { maximum: 280 }, allow_nil: true
  validate :body_or_origin_must_be_present

  private

  def body_or_origin_must_be_present
    if body.blank? && origin.blank?
      errors.add(:base, "Either body or origin must be present")
    end
  end
end
