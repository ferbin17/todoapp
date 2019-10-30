# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :shares
  has_many :todos, through: :shares, dependent: :destroy

  # has_many :todos, dependent: :destroy
  has_many :comments, dependent: :destroy

  scope :all_user_except_one, ->(user) { where('id != ?', user.id) }
  scope :shared_users, ->(id) { where('todo_id=? AND is_owner=false', id).order(:user_id) }
  scope :user_join_shares, ->(id) { joins(:shares).select('users.*,shares.*').shared_users(id) }
  scope :get_shared_users, ->(todo) { joins(:shares).select('users.*,shares.*').where('shares.todo_id = ? and shares.user_id != ?', todo.id, todo.user_id) }
  scope :get_comments, ->(todo) { joins(:comments).select('users.*,comments.*').where('comments.todo_id = ?', todo.id) }

  #fetch acitve todos of a todos
  def active_todos
    todos.select_shares_and_todo.active_status_todos(true).order_by(:desc)
  end

  # returns either all active todos or all inactive_only todos
  def active_or_inactive_todos(active_status)
    flag = active_status == 'active_only'
    todos.select_shares_and_todo.active_status_todos(flag).order_by(:desc)
  end

  # Searching todo, returns all active todos if keyword is not present else returns the search results
  def search_todo(search_key)
    like_keyword = "%#{search_key}%"
    like_keyword == '%%' ? todos.select_shares_and_todo.active_status_todos(true).order_by(:desc) : todos.select_shares_and_todo.search(like_keyword).order_by(:desc)
  end

end
