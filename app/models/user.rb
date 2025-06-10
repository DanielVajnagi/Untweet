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
class User < ApplicationRecord
  update_index("user_index") { self }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable :recoverable,
  devise :database_authenticatable, :registerable,
          :rememberable, :validatable

  enum role: { user: "user", admin: "admin", superadmin: "superadmin" }, _suffix: true

  validates :encrypted_password, presence: true
  validates :username, presence: true
  validates :email, presence: true
  validates :email, uniqueness: { case_sensitive: false }
  validates :username, uniqueness: { case_sensitive: false }

  has_many :tweets, dependent: :nullify
  has_many :comments, dependent: :nullify
  has_many :likes, dependent: :nullify

  attr_accessor :login

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)

    return nil unless login.present?

    where(conditions.to_h).where([ "lower(username) = :value OR lower(email) = :value", { value: login.downcase } ]).first
  end

  def is_admin?
    admin_role? || superadmin_role?
  end

  def is_superadmin?
    superadmin_role?
  end

  def active_for_authentication?
    super && !banned?
  end

  def inactive_message
    banned? ? :banned : super
  end
end
