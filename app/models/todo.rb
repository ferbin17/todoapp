class Todo < ApplicationRecord

  validates_presence_of :body

  belongs_to :user

  has_many :shares
  has_many :users, through: :shares, dependent: :destroy

  has_many :comments, dependent: :destroy

  scope :user_shared_todos, lambda { |current_user| Todo.joins(:shares).select("shares.*,todos.*").where("shares.user_id= ?", current_user.id).order(position: :desc) }
  scope :user_shared_partial_todos, lambda { |active_status, current_user| Todo.joins(:shares).select("shares.*,todos.*").where("todos.active=? and shares.user_id= ?", active_status, current_user.id).order(position: :desc) }
  scope :previous_todo, lambda { |current_todo, current_user| Todo.joins(:shares).select("shares.*,todos.*").where("position < ? and shares.user_id= ? and todos.active=?", current_todo.position, current_user.id, current_todo.active?).order(position: :desc).limit(1) }
  scope :next_todo, lambda { |current_todo, current_user| Todo.joins(:shares).select("shares.*,todos.*").where("position > ? and shares.user_id= ? and todos.active=?", current_todo.position, current_user.id, current_todo.active?).order(position: :asc).limit(1) }
  scope :search, lambda { |like_keyword| where("body LIKE ?", like_keyword) }
  scope :active_only, ->  { where(active: true) }
  scope :inactive_only, -> { where(active: false) }

  #function to sort todos with respect to posistion in descending order
  def self.sort
    @todos = Todo.all
    return @todos.order(position: :desc)
  end

  def self.move(direction, current_todo, current_user)
    @user = User.find(current_user.id)
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
