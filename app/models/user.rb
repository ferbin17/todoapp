class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :shares
  has_many :todos, through: :shares, dependent: :destroy

  has_many :todos, dependent: :destroy
  has_many :comments, dependent: :destroy

  scope :shared_users, lambda { |id| where("todo_id=? AND is_owner=false", id).order(:user_id) }
end
