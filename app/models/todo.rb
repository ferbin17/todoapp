class Todo < ApplicationRecord

  validates_presence_of :body

  belongs_to :user

  # after_save :update_position
  # after_destroy :update_position

  has_many :comments, dependent: :destroy

  scope :search, lambda { |like_keyword| where("body LIKE ?", like_keyword) }
  scope :logged_user, lambda { |current_user| where(user_id: current_user.id) }
  scope :active_only, ->  { where(active: true).order(position: :desc) }
  scope :inactive_only, -> { where(active: false).order(position: :desc) }

  #function to sort todos with respect to posistion in descending order
  def self.sort
    @todos = Todo.all
    return @todos.order(position: :desc)
  end

  def self.move(direction, id, current_user)
    case direction
    when "down"
      @todo = Todo.find(id)
      @nexttodo = Todo.where("position < ? AND user_id = ? AND active = ?", @todo.position, current_user.id, @todo.active?).order(position: :desc).limit(1)
      position = @nexttodo[0].position
      @nexttodo.update(position: @todo.position)
      @todo.update(position: position)

    when "up"
      @todo = Todo.find(id)
      @nexttodo = Todo.where("position > ? AND user_id = ? AND active = ?", @todo.position, current_user.id, @todo.active?).order(position: :asc).limit(1)
      position = @nexttodo[0].position
      @nexttodo.update(position: @todo.position)
      @todo.update(position: position)
    end
  end


end
