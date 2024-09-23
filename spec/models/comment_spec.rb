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
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:tweet) }

  it { is_expected.to validate_presence_of(:body) }
  it { is_expected.to validate_length_of(:body).is_at_most(280) }
end
