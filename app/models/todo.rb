
class Todo < ApplicationRecord
  validates_presence_of :body

  # belongs_to :user

  has_many :shares
  has_many :users, through: :shares, dependent: :destroy

  has_many :comments, dependent: :destroy

  scope :select_shares_and_todo, -> { select('shares.*,todos.*') }
  scope :active_status_todos, ->(active_status) { where(active: active_status) }
  scope :order_by, ->(order) { order(position: order)}
  scope :logged_user, ->(current_user) { where(user_id: current_user.id) }
  scope :search, ->(like_keyword) { where('body LIKE ?', like_keyword) }
  scope :active_only, -> { where(active: true) }
  scope :inactive_only, -> { where(active: false) }
  scope :previous_todo, ->(current_user, current_todo) { current_user.todos.select_shares_and_todo.where("position < ?", current_todo.position).active_status_todos(current_todo.active?).order_by(:desc).limit(1) }
  scope :next_todo, ->(current_user, current_todo) { current_user.todos.select_shares_and_todo.where("position > ?", current_todo.position).active_status_todos(current_todo.active?).order_by(:asc).limit(1) }
  self.per_page = 5

  # function to todos with respect to their params
  def self.find_mode_and_return_todos(params, current_user)
    if params.key?(:search)
      search_todo(params[:search], current_user)
    else
      active_or_inactive_todos(params[:active_status], current_user)
    end
  end

  # Searching todo, returns all active todos if keyword is not present else returns the search results
  def self.search_todo(search_key, current_user)
    like_keyword = "%#{search_key}%"
    like_keyword == '%%' ? current_user.todos.select_shares_and_todo.active_status_todos(true).order_by(:desc) : current_user.todos.select_shares_and_todo.search(like_keyword).order_by(:desc)
  end

  # returns either all active todos or all inactive_only todos
  def self.active_or_inactive_todos(active_status, current_user)
    active_status == 'active_only' ?
      current_user.todos.select_shares_and_todo.active_status_todos(true).order_by(:desc) :
      current_user.todos.select_shares_and_todo.active_status_todos(false).order_by(:desc)
  end

  # function to create a entry in todo table
  def self.create_entry_in_todo(params, current_user)
    body = { 'body' => params[:create] }
    todo = Todo.new(body.merge('user_id' => current_user.id))
    if todo.save
      Share.create_entry_in_share(todo, current_user)
      current_user.todos.select_shares_and_todo.where(id: todo.id).active_status_todos(true).order_by(:desc)[0]
    end
  end

  # fucntion to move/change the posisiton values of two adajacent todos, either up or down
  def self.move(direction, current_todo, current_user)
    case direction
    when 'down'
      previous_todo = Todo.previous_todo(current_user, current_todo)
      position = previous_todo[0].position
      previous_todo = previous_todo[0].shares.where(user_id: current_user.id)
      current_todo = current_todo.shares.where(user_id: current_user.id)
      previous_todo[0].update(position: current_todo[0].position)
      current_todo[0].update(position: position)
    when 'up'
      nexttodo = Todo.next_todo(current_user, current_todo)
      position = nexttodo[0].position
      nexttodo = nexttodo[0].shares.where(user_id: current_user.id)
      nexttodo[0].update(position: current_todo.position)
      current_todo = current_todo.shares.where(user_id: current_user.id)
      current_todo[0].update(position: position)
    end
  end
end
