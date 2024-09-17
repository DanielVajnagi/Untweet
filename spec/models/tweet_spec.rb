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
require 'rails_helper'

RSpec.describe Tweet, type: :model do
  # Association tests using Shoulda Matchers
  it { should belong_to(:user) }
  it { should belong_to(:origin).class_name('Tweet').optional }
  it { should have_many(:retweets).class_name('Tweet').with_foreign_key('origin_id') }
  it { should have_many(:likes) }
  it { should have_many(:comments) }

  # Validation tests using Shoulda Matchers
  it { should validate_length_of(:body).is_at_most(280) }

  # Setup a user and origin tweet using let
  let(:user) { User.create!(email: 'test@example.com', password: 'password', username: 'testuser') }
  let(:origin_tweet) { Tweet.create!(body: 'Original tweet', user: user) }

  describe 'custom validation: body_or_origin_must_be_present' do
    let(:tweet_with_body) { Tweet.new(body: 'This is a tweet', user: user) }
    let(:retweet) { Tweet.new(user: user, origin: origin_tweet) }
    let(:tweet_without_body_or_origin) { Tweet.new(user: user) }

    it 'is valid if the body is present' do
      expect(tweet_with_body).to be_valid
    end

    it 'is valid if the origin is present' do
      expect(retweet).to be_valid
    end

    it 'is invalid if both body and origin are blank' do
      expect(tweet_without_body_or_origin).not_to be_valid
      expect(tweet_without_body_or_origin.errors[:base]).to include('Either body or origin must be present')
    end
  end
end
