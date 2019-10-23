class Todo < ApplicationRecord

  validates_presence_of :body

  belongs_to :user

  has_many :shares
  has_many :users, through: :shares, dependent: :destroy

  has_many :comments, dependent: :destroy

  scope :todo_join_shares, ->  { joins(:shares).select("shares.*,todos.*") }
  scope :active_inactive, lambda { |active_status| where("todos.active=?",active_status) }
  scope :user_shared_todos, lambda { |current_user| todo_join_shares.where("shares.user_id= ?", current_user.id).order(position: :desc) }
  scope :user_shared_partial_todos, lambda { |active_status, current_user| todo_join_shares.active_inactive( active_status).where("shares.user_id= ?", current_user.id).order(position: :desc) }
  scope :previous_todo, lambda { |current_todo, current_user| todo_join_shares.user_shared_todos(current_user).active_inactive( current_todo.active?).where("position < ?", current_todo.position).order(position: :desc).limit(1) }
  scope :next_todo, lambda { |current_todo, current_user| todo_join_shares.user_shared_todos(current_user).active_inactive(current_todo.active?).where("position > ?", current_todo.position).order(position: :asc).limit(1) }
  scope :logged_user, lambda { |current_user| where(user_id: current_user.id) }
  scope :search, lambda { |like_keyword| where("body LIKE ?", like_keyword) }
  scope :active_only, ->  { where(active: true) }
  scope :inactive_only, -> { where(active: false) }

  #function to sort todos with respect to posistion in descending order
  def self.sort
    @todos = Todo.all
    return @todos.order(position: :desc)
  end

  def self.move(direction, current_todo, current_user)
    @user = User.find_by(id: current_user.id)
    case direction
    when "down"
      @nexttodo = Todo.previous_todo(current_todo, current_user)

      current_todo = current_todo.shares.where(user_id: current_user.id)
      @nexttodo = @nexttodo[0].shares.where(user_id: current_user.id)
      #
      position = @nexttodo[0].position
      @nexttodo[0].update(position: current_todo[0].position)
      current_todo[0].update(position: position)
    when "up"
      @nexttodo = Todo.next_todo(current_todo, current_user)

      current_todo = current_todo.shares.where(user_id: current_user.id)
      @nexttodo = @nexttodo[0].shares.where(user_id: current_user.id)

      position = @nexttodo[0].position
      @nexttodo[0].update(position: current_todo[0].position)
      current_todo[0].update(position: position)
    end
  end


end
