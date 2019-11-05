# frozen_string_literal: true

class Todo < ApplicationRecord
  validates_presence_of :body

  # belongs_to :user

  has_many :shares
  has_many :users, through: :shares, dependent: :destroy

  has_many :comments, dependent: :destroy

  scope :select_shares_and_todo, -> { select('shares.*,todos.*') }
  scope :active_status_todos, ->(active_status) { where(active: active_status) }
  scope :order_by, ->(order) { order(position: order) }
  scope :logged_user, ->(current_user) { where(user_id: current_user.id) }
  scope :search, ->(like_keyword, params) { select_shares_and_todo.where('body LIKE ?', like_keyword).order_by(:desc).pagination(params) }
  scope :active_only, -> { where(active: true) }
  scope :inactive_only, -> { where(active: false) }
  scope :pagination, ->(params) { paginate(page: params[:page]) }
  scope :todo_join_shares, ->(active_status, params) { select_shares_and_todo.active_status_todos(active_status).order_by(:desc).pagination(params) }

  self.per_page = 5

  # function to todos with respect to their params
  def self.find_mode_and_return_todos(params, current_user)
    if params.key?(:search)
      current_user.search_todo(params[:search], params)
    else
      current_user.active_or_inactive_todos(params)
    end
  end

  # function to create a entry in todo table
  def self.create_entry_in_todo(params, current_user)
    body = { 'body' => params[:create] }
    todo = Todo.new(body)
    if todo.save
      Share.create_entry_in_share(todo, current_user)
      current_user.todos.select_shares_and_todo.where(id: todo.id)[0]
    else
      # show errors
      { errors: todo.errors.full_messages }
    end
  end

  def self.set_parameters_for_move(direction, current_todo, current_user)
    if direction == 'down'
      Todo.check_move('down', current_todo, current_user)
    else
      Todo.check_move('up', current_todo, current_user)
    end
  end

  # fucntion to check if move/change the posisiton values of two adajacent todos, either up or down is possible or not
  def self.check_move(direction, current_todo, current_user)
    todo = fetch_todo(direction, current_todo, current_user)
    if todo.present?
      move(current_todo, todo, current_user)
    else
      # show erros
      { errors: ["Todo not found"] }
    end
  end

  # fucntion to check if move/change the posisiton values of two adajacent todos, either up or down if possible
  def self.move(current_todo, todo, current_user)
    position = todo[0].position
    todo = todo[0].shares.logged_user(current_user)
    current_todo = current_todo.shares.logged_user(current_user)
    todo[0].update(position: current_todo[0].position)
    current_todo[0].update(position: position)
  end

  #function to fetch previous or next todo depending on direction
  def self.fetch_todo(direction, current_todo, current_user)
    case direction
    when 'down'
      current_user.previous_todo(current_todo)
    when 'up'
      current_user.next_todo(current_todo)
    end
  end
end
