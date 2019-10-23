class Share < ApplicationRecord
  has_many :todos
  belongs_to :user
  belongs_to :todo

  scope :shared_users, lambda { |id| where("todo_id=? AND is_owner=false", id).order(:user_id) }
  scope :select_iser_id, lambda { select('user_id') }
end
