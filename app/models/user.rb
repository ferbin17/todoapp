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

  #f etch acitve todos of a todos
  def active_todos(params)
    todos.todo_join_shares(true, params)
  end

  # returns either all active todos or all inactive_only todos
  def active_or_inactive_todos(params)
    flag = params[:active_status] == 'active_only'
    todos.todo_join_shares(flag, params)
  end

  # function to get a todo along with its user details
  def get_a_todo(params)
    todos.select_shares_and_todo.where(id: params[:id])[0]
  end

  # Searching todo, returns all active todos if keyword is not present else returns the search results
  def search_todo(search_key, params)
    if search_key.present?
      todos.search("%#{search_key}%", params)
    else
      todos.todo_join_shares(true, params)
    end
  end

end
