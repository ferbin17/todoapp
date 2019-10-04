class Todo < ApplicationRecord
  validates_presence_of :body
  belongs_to :user

  #function to sort todos with respect to posistion in descending order
  def self.sort
    @todos = Todo.all
    return @todos.order(position: :desc)
  end

  #function to fetch all active todos with respect to posistion in descending order
  def self.active_only
    Todo.where(active: true).order(position: :desc)
  end

  #funtion to fetch all inactive todos with respect to posistion in descending order
  def self.inactive_only
    Todo.where(active: false).order(position: :desc)
  end

  #function to update position value with respect to posistion in descending order
  def self.update_position
    Todo.where(active: true).order(:updated_at).each.with_index(1) do |todo, index|
      todo.update_column :position, index
    end

    Todo.where(active: false).order(:updated_at).each.with_index(10000) do |todo, index|
      todo.update_column :position, index
    end
  end

end
