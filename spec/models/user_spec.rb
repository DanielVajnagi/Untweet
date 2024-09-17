# == Schema Information
#
# Table name: users
#
#  id                  :bigint           not null, primary key
#  email               :string           default(""), not null
#  encrypted_password  :string           default(""), not null
#  username            :string           default(""), not null
#  remember_created_at :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
require 'rails_helper'

RSpec.describe User, type: :model do
  # Association tests
  it { should have_many(:tweets) }
  it { should have_many(:comments) }
  it { should have_many(:likes) }

  # Validation tests 
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:encrypted_password) }
  it { should validate_presence_of(:username) }

  it { should validate_uniqueness_of(:email).case_insensitive }
  it { should validate_uniqueness_of(:username).case_insensitive }

  # Email format validation
  it { should allow_value('user@example.com').for(:email) }
  it { should_not allow_value('userexample.com').for(:email) }
end
