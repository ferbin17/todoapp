
class Todo < ApplicationRecord
  validates_presence_of :body

  belongs_to :user

  has_many :shares
  has_many :users, through: :shares, dependent: :destroy

  has_many :comments, dependent: :destroy

  scope :todo_join_shares, -> { joins(:shares).select('shares.*,todos.*') }
  scope :active_inactive, ->(active_status) { where('todos.active=?', active_status) }
  scope :user_shared_todos, ->(current_user) { todo_join_shares.where('shares.user_id= ?', current_user.id).order(position: :desc) }
  scope :user_shared_partial_todos, ->(active_status, current_user) { todo_join_shares.active_inactive(active_status).where('shares.user_id= ?', current_user.id).order(position: :desc) }
  scope :previous_todo, ->(current_todo, current_user) { todo_join_shares.user_shared_todos(current_user).active_inactive(current_todo.active?).where('position < ?', current_todo.position).order(position: :desc).limit(1) }
  scope :next_todo, ->(current_todo, current_user) { todo_join_shares.user_shared_todos(current_user).active_inactive(current_todo.active?).where('position > ?', current_todo.position).order(position: :asc).limit(1) }
  scope :logged_user, ->(current_user) { where(user_id: current_user.id) }
  scope :search, ->(like_keyword) { where('body LIKE ?', like_keyword) }
  scope :active_only, -> { where(active: true) }
  scope :inactive_only, -> { where(active: false) }

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
    like_keyword == '%%' ? Todo.user_shared_partial_todos(true, current_user) : Todo
      .user_shared_todos(current_user).search(like_keyword)
  end

  # returns either all active todos or all inactive_only todos
  def self.active_or_inactive_todos(active_status, current_user)
    active_status == 'active_only' ?
      Todo.user_shared_partial_todos(true, current_user) :
      Todo.user_shared_partial_todos(false, current_user)
  end

  # function to create a entry in todo table
  def self.create_entry_in_todo(params, current_user)
    body = { 'body' => params[:create] }
    todo = Todo.new(body.merge('user_id' => current_user.id))
    if todo.save
      Share.create_entry_in_share(todo, current_user)
      Todo.user_shared_partial_todos(true, current_user).where(id: todo.id)[0]
    end
  end

  # fucntion to move/change the posisiton values of two adajacent todos, either up or down
  def self.move(direction, current_todo, current_user)
    user = User.find_by(id: current_user.id)
    case direction
    when 'down'
      nexttodo = Todo.previous_todo(current_todo, current_user)

      current_todo = current_todo.shares.where(user_id: current_user.id)
      nexttodo = nexttodo[0].shares.where(user_id: current_user.id)
      position = nexttodo[0].position
      nexttodo[0].update(position: current_todo[0].position)
      current_todo[0].update(position: position)
    when 'up'
      nexttodo = Todo.next_todo(current_todo, current_user)

      current_todo = current_todo.shares.where(user_id: current_user.id)
      nexttodo = nexttodo[0].shares.where(user_id: current_user.id)

      position = nexttodo[0].position
      nexttodo[0].update(position: current_todo[0].position)
      current_todo[0].update(position: position)
    end
  end
end
