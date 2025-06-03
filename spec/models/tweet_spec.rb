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
  let(:user) { User.create!(email: 'test@example.com', password: 'password', username: 'testuser') }
  let(:tweet) { Tweet.new(user: user) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:origin).class_name('Tweet').optional }
  it { is_expected.to have_many(:retweets).class_name('Tweet').with_foreign_key('origin_id') }
  it { is_expected.to have_many(:likes) }
  it { is_expected.to have_many(:comments) }

  it { is_expected.to validate_length_of(:body).is_at_most(280) }

  context 'when origin is present' do
    before do
      tweet.origin = Tweet.new(user: user, body: 'Original tweet')
      tweet.body = nil
    end

    it 'allows body to be nil' do
      expect(tweet).to be_valid
    end
  end

  context 'when origin is not present' do
    before do
      tweet.origin = nil
      tweet.body = nil
    end

    it 'does not allow body to be nil' do
      expect(tweet).not_to be_valid
    end
  end
end
