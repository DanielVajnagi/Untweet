# == Schema Information
#
# Table name: comments
#
#  id         :bigint           not null, primary key
#  body       :string           not null
#  user_id    :bigint           not null
#  tweet_id   :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Comment, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:tweet) }

  it { should validate_presence_of(:body) }
  it { should validate_length_of(:body).is_at_most(280) }
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:tweet_id) }
end
