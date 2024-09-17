# == Schema Information
#
# Table name: likes
#
#  id         :bigint           not null, primary key
#  tweet_id   :bigint           not null
#  user_id    :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Like < ApplicationRecord
  belongs_to :user
  belongs_to :tweet

  validates :user_id, presence: true
  validates :tweet_id, presence: true
end
